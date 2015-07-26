package com.mycompany.app;

import java.io.File;
import java.io.InputStream;
import java.io.StringWriter;
import java.lang.StringBuilder;
import java.lang.RuntimeException;


import java.util.concurrent.TimeUnit;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.Hashtable;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.commons.io.FileUtils;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.OutputType;
import org.apache.commons.io.FilenameUtils;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import org.openqa.selenium.interactions.Actions;


import org.apache.commons.io.FileUtils;


import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.interactions.Action;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import    org.openqa.selenium.Dimension;

import org.openqa.selenium.Platform;
import org.apache.http.message.BasicHttpEntityEnclosingRequest;

import org.openqa.selenium.interactions.Actions;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import org.openqa.selenium.By;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.remote.HttpCommandExecutor;
import org.openqa.selenium.remote.RemoteWebDriver;

import org.openqa.selenium.firefox.FirefoxDriver;
// import org.openqa.selenium.firefox.ProfileManager;
import org.openqa.selenium.firefox.internal.ProfilesIni;
import org.openqa.selenium.firefox.FirefoxProfile;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;


import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.BindException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.charset.Charset;

import org.junit.Assert;
import static org.junit.Assert.*;

public class App
{


static WebDriver driver;

public static void main(String[] args) throws InterruptedException,java.io.IOException {

	DesiredCapabilities capabilities = DesiredCapabilities.firefox();

	capabilities =   new DesiredCapabilities("firefox", "", Platform.ANY);
	FirefoxProfile profile = new ProfilesIni().getProfile("default");
	capabilities.setCapability("firefox_profile", profile);
	// run embedded
	driver = new FirefoxDriver(capabilities);
	// run remote
	// driver = new RemoteWebDriver(capabilities);

	// Wait For Page To Load
	driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);

	// Go to URL
	driver.get("http://www.hollandamerica.com/");

	// Maximize Window
	driver.manage().window().maximize();

	// Wait For Page To Load
	driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);


	String value0 = "pnav-destinations";
	String title0  = null;
	title0  = "Destinations & Excursions - opens submenu";
	title0  = "Destinations - opens submenu";
	String css_selector0 = String.format("a#%s", value0);
	// Hover over menu
	WebElement element0 =  driver.findElement(By.cssSelector(css_selector0));
	Actions a1 = new Actions(driver);
	a1.moveToElement(element0).build().perform();
	// http://junit.sourceforge.net/javadoc/org/junit/Assert.html
	// assertEquals(200, response.getStatusLine().getStatusCode());
	assertTrue(String.format("Unexpected title '%s'", element0.getAttribute("title")), element0.getAttribute("title").matches(title0) );
/*
        String value1  = "/cruise-destinations/alaska?WT.ac=pnav_DestMap_Alaska";
        String text1   = "Alaska & Yukon";
        String title1  = "Alaska Cruise Vacations";

        String css_selector1 = String.format("a[href='%s']", value1);
        WebDriverWait wait = new WebDriverWait(driver, 1);
        wait.withTimeout(1, TimeUnit.SECONDS).pollingEvery(150, TimeUnit.MICROSECONDS );
        wait.until(ExpectedConditions.elementToBeClickable(By.cssSelector(css_selector1)));
        // WebElement element1 = driver.findElement(By.cssSelector(css_selector1));
        WebElement element1 = find_element("css_selector", css_selector1) ;
        assertTrue(String.format("Unexpected text '%s'" , element1.getText()), element1.getText().matches(text1) );
        System.out.println(String.format("Click on '%s'", element1.getText()));
        new Actions(driver).moveToElement(element1).click().build().perform();
        Thread.sleep(3000L);
        assertTrue(driver.getTitle(),driver.getTitle().contains(title1));
        driver.navigate().back();
 */
	//take a screenshot
	File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);
	String currentDir = System.getProperty("user.dir");
	//save the screenshot in png format on the disk.
	FileUtils.copyFile(scrFile, new File(FilenameUtils.concat(currentDir, "screenshot.png")));

	//closing current driver window
	driver.close();
}
// http://selenium-interview-questions.blogspot.in/2014/02/how-to-take-screenshot-of-webpage-using.html


// http://www.adam-bien.com/roller/abien/entry/named_parameters_in_java_8
// does nothing exist prior to java 8 ?

private WebElement find_element(String selector_type, String selector_value){
	int flexible_wait_interval = 5;
	long wait_polling_interval = 500;
	WebDriverWait wait = new WebDriverWait(driver, flexible_wait_interval );
	wait.pollingEvery(wait_polling_interval,TimeUnit.MILLISECONDS);
	WebElement element = null;

	Hashtable<String, Boolean> supported_selectors = new Hashtable<String, Boolean>();
	supported_selectors.put("id", true);
	supported_selectors.put("css_selector", true);
	supported_selectors.put("xpath", true);
	supported_selectors.put("partial_link_text", false);
	supported_selectors.put("link_text", true);
	supported_selectors.put("classname", false);

	if (selector_type == null || !supported_selectors.containsKey(selector_type) || !supported_selectors.get(selector_type)) {
		return null;
	}
	if (selector_type == "id") {

		try {
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.id(selector_value)));
		} catch (RuntimeException timeoutException) {
		return null;
		}
		element = driver.findElement(By.id(selector_value));
	}

	if (selector_type == "id") {

		try {
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.id(selector_value)));
		} catch (RuntimeException timeoutException) {
			return null;
		}
		element = driver.findElement(By.id(selector_value));
	}


	if (selector_type == "link_text") {

		try {
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.linkText(selector_value)));
		} catch (RuntimeException timeoutException) { 
			return null;
		}
		element = driver.findElement(By.linkText(selector_value));
	}


	if (selector_type == "css_selector") {

		try {
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector(selector_value)));
		} catch (RuntimeException timeoutException) {
			return null;
		}
		element = driver.findElement(By.cssSelector(selector_value));
	}


	if (selector_type == "xpath") {

		try {
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath(selector_value)));
		} catch (RuntimeException timeoutException) {
			return null;
		}
		element = driver.findElement(By.xpath(selector_value));
	}

	return element;
}

}


