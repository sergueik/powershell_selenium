package com.mycompany.app;

import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.lang.StringBuilder;
import java.net.BindException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHttpEntityEnclosingRequest;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import org.openqa.selenium.By;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.JavascriptExecutor;
// import org.openqa.selenium.firefox.ProfileManager;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxProfile;
import org.openqa.selenium.logging.LoggingPreferences;
import java.util.logging.Level;
import org.openqa.selenium.logging.LogEntries;
import org.openqa.selenium.logging.LogEntry;
import org.openqa.selenium.logging.LogType;
import org.openqa.selenium.logging.LoggingPreferences;
import org.openqa.selenium.remote.CapabilityType;
import org.openqa.selenium.remote.DesiredCapabilities;

import org.openqa.selenium.firefox.internal.ProfilesIni;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.Platform;
import org.openqa.selenium.remote.HttpCommandExecutor;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import org.testng.annotations.*;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.*;

public class AppTest // extends BaseTest
{

public RemoteWebDriver driver = null;
public String selenium_host = null;
public String selenium_port = null;
public String selenium_browser = null;
public String selenium_run = null;

@BeforeSuite(alwaysRun = true)
public void setupBeforeSuite( ITestContext context ) throws InterruptedException,MalformedURLException {
	// http://www.programcreek.com/java-api-examples/index.php?api=org.testng.ITestContext
	selenium_host = context.getCurrentXmlTest().getParameter("selenium.host");
	selenium_port = context.getCurrentXmlTest().getParameter("selenium.port");
	selenium_browser = context.getCurrentXmlTest().getParameter("selenium.browser");
	selenium_run = context.getCurrentXmlTest().getParameter("selenium.run");

	// Remote Configuration
	if (selenium_browser.compareToIgnoreCase("remote") == 0) { 
		String hub = "http://"+  selenium_host  + ":" + selenium_port   +  "/wd/hub";

		LoggingPreferences logging_preferences = new LoggingPreferences();
		logging_preferences.enable(LogType.BROWSER, Level.ALL);
		logging_preferences.enable(LogType.CLIENT, Level.INFO);
		logging_preferences.enable(LogType.SERVER, Level.INFO);

		if (selenium_browser.compareToIgnoreCase("chrome") == 0) {
			DesiredCapabilities capabilities =   new DesiredCapabilities("chrome", "", Platform.ANY);
			capabilities.setBrowserName("chrome");
			capabilities.setCapability(CapabilityType.LOGGING_PREFS, logging_preferences);

			try {
				driver = new RemoteWebDriver(new URL("http://"+  selenium_host  + ":" + selenium_port   +  "/wd/hub"), capabilities);
			} catch (MalformedURLException ex) { }
		} else {

			DesiredCapabilities capabilities =   new DesiredCapabilities("firefox", "", Platform.ANY);
			capabilities.setBrowserName("firefox");

			FirefoxProfile profile = new ProfilesIni().getProfile("default");
			capabilities.setCapability("firefox_profile", profile);
			capabilities.setCapability(CapabilityType.LOGGING_PREFS, logging_preferences);

			try {
				driver = new RemoteWebDriver(new URL("http://"+  selenium_host  + ":" + selenium_port   +  "/wd/hub"), capabilities);
			} catch (MalformedURLException ex) { }
		}

	} 
	// standalone
	else { 
		if (selenium_browser.compareToIgnoreCase("chrome") == 0) {
			System.setProperty("webdriver.chrome.driver", "c:/java/selenium/chromedriver.exe");
			DesiredCapabilities capabilities = DesiredCapabilities.chrome();
			LoggingPreferences logging_preferences = new LoggingPreferences();
			logging_preferences.enable(LogType.BROWSER, Level.ALL);
			capabilities.setCapability(CapabilityType.LOGGING_PREFS, logging_preferences);
			/*
			   prefs.js:user_pref("extensions.logging.enabled", true);
			   user.js:user_pref("extensions.logging.enabled", true);
			 */
			driver = new ChromeDriver(capabilities);
			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		} else {
			DesiredCapabilities capabilities = DesiredCapabilities.firefox();
			LoggingPreferences logging_preferences = new LoggingPreferences();
			logging_preferences.enable(LogType.BROWSER, Level.ALL);
			capabilities.setCapability(CapabilityType.LOGGING_PREFS, logging_preferences);

			driver = new FirefoxDriver(capabilities);
		}
	}
	try{
		driver.manage().window().setSize(new Dimension(600, 800));
		driver.manage().timeouts().pageLoadTimeout(10, TimeUnit.SECONDS);
		driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
	}  catch(Exception ex) {
		System.out.println(ex.toString());
	}

}

@AfterSuite(alwaysRun = true,enabled =true)
public void cleanupSuite() {
	driver.close();
	driver.quit();
}

@Test(description="Opens the site")
public void LoggingTest() throws InterruptedException {
	String base_url = "http://www.cnn.com/";
	driver.get(base_url);
	WebDriverWait wait = new WebDriverWait(driver, 5);
        
	String value1 = null;
        String class_name = "logo";
	wait.until(ExpectedConditions.visibilityOfElementLocated(By.className(class_name)));
	WebElement element = driver.findElement(By.className(class_name));
	if (driver instanceof JavascriptExecutor) {
        	((JavascriptExecutor)driver).executeScript("arguments[0].style.border='3px solid yellow'", element);
	}
	Thread.sleep(3000L);
	Actions builder = new Actions(driver);
	builder.moveToElement(element).click().build().perform();
	analyzeLog();
}


public void analyzeLog() {
	LogEntries logEntries = driver.manage().logs().get(LogType.BROWSER);

	for (LogEntry entry : logEntries) {
		System.out.println(new Date(entry.getTimestamp()) + " " + entry.getLevel() + " " + entry.getMessage());
	}
}

@Test(description="Takes screen shot - is actually a utility")
public void test2() throws InterruptedException {
	//take a screenshot
	//File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);
	//save the screenshot in png format on the disk.
	//FileUtils.copyFile(scrFile, new File(System.getProperty("user.dir") + "\\screenshot.png"));
}


private static JSONObject extractObject(HttpResponse resp) throws IOException, JSONException {
	InputStream contents = resp.getEntity().getContent();
	StringWriter writer = new StringWriter();
	IOUtils.copy(contents, writer, "UTF8");
	JSONObject objToReturn = new JSONObject(writer.toString());
	return objToReturn;
}
}


