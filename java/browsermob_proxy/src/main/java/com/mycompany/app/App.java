// https://groups.google.com/forum/#!topic/webdriver/aQl5o0TorqM
// http://amormoeba.blogspot.com/2014/02/how-to-use-browser-mob-proxy.html
// http://www.assertselenium.com/browsermob-proxy/performance-data-collection-using-browsermob-proxy-and-selenium/
package com.mycompany.app;

import java.io.File;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.lang.StringBuilder;
import java.util.concurrent.TimeUnit;
import org.apache.commons.io.IOUtils;
import org.apache.commons.io.FileUtils;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openqa.selenium.WebElement;


import net.lightbody.bmp.proxy.ProxyServer;
import net.lightbody.bmp.core.har.Har;

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
import org.openqa.selenium.remote.CapabilityType;
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

public class App
{

public static RemoteWebDriver driver = null;
public static String selenium_host = null;
public static String selenium_port = null;
public static String selenium_browser = null;
public static String selenium_run = null;

public static void main(String[] args) throws InterruptedException {

	selenium_host = "localhost";
	selenium_port = "4444";
	selenium_browser = "firefox";
	selenium_run = "local";

	// start the proxy
	ProxyServer server = new ProxyServer(4444);
	server.start();
//captures the moouse movements and navigations
	server.setCaptureHeaders(true);
	server.setCaptureContent(true);

// get the Selenium proxy object
	org.openqa.selenium.Proxy proxy = server.seleniumProxy();
	if (selenium_browser.compareToIgnoreCase("remote") == 0) { // Remote Configuration

		String hub = "http://"+  selenium_host  + ":" + selenium_port   +  "/wd/hub";

		if (selenium_browser.compareToIgnoreCase("chrome") == 0) {
			DesiredCapabilities capabilities =   new DesiredCapabilities("chrome", "", Platform.ANY);
			capabilities.setBrowserName("chrome");

			try {
				driver = new RemoteWebDriver(new URL("http://"+  selenium_host  + ":" + selenium_port   +  "/wd/hub"), capabilities);
			} catch (MalformedURLException ex) { }
		} else {

			DesiredCapabilities capabilities =   new DesiredCapabilities("firefox", "", Platform.ANY);
			capabilities.setBrowserName("firefox");

			FirefoxProfile profile = new ProfilesIni().getProfile("default");
			capabilities.setCapability("firefox_profile", profile);

			try {
				driver = new RemoteWebDriver(new URL("http://"+  selenium_host  + ":" + selenium_port   +  "/wd/hub"), capabilities);
			} catch (MalformedURLException ex) { }
		}

	} else { // standalone
		if (selenium_browser.compareToIgnoreCase("chrome") == 0) {
			System.setProperty("webdriver.chrome.driver", "c:/java/selenium/chromedriver.exe");
			DesiredCapabilities capabilities = DesiredCapabilities.chrome();
			capabilities.setCapability(CapabilityType.PROXY, proxy);
			driver = new ChromeDriver(capabilities);

		} else {
			DesiredCapabilities capabilities = DesiredCapabilities.firefox();
			capabilities.setCapability(CapabilityType.PROXY, proxy);

		}
	}
	try{

// create a new HAR
		server.newHar("m.carnival.com");
		driver.manage().window().setSize(new Dimension(600, 800));
		driver.manage().timeouts().pageLoadTimeout(50, TimeUnit.SECONDS);
		driver.manage().timeouts().implicitlyWait(20, TimeUnit.SECONDS);
	}  catch(Exception ex) {
		System.out.println(ex.toString());
	}
	try{

		driver.get("http://m.carnival.com/");
		WebDriverWait wait = new WebDriverWait(driver, 30);
		String value1 = null;

		wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("ccl-logo")));
		value1 = "ddlDestinations";

		String xpath_selector1 = String.format("//select[@id='%s']", value1);
		wait.until(ExpectedConditions.elementToBeClickable(By.xpath(xpath_selector1)));
		WebElement element = driver.findElement(By.xpath(xpath_selector1));

		System.out.println( element.getAttribute("id"));
		Actions builder = new Actions(driver);
		builder.moveToElement(element).build().perform();

		String csspath_selector2 = "div.find-cruise-submit > a";
		WebElement element2 = driver.findElement(By.cssSelector(csspath_selector2));
		System.out.println( element2.getText());
		new Actions(driver).moveToElement(element2).click().build().perform();
		Thread.sleep(5000);

		// print the node information
		//String result = getIPOfNode(driver);
		//System.out.println(result);

		//take a screenshot
		//File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);

		//save the screenshot in png format on the disk.
		//FileUtils.copyFile(scrFile, new File(System.getProperty("user.dir") + "\\screenshot.png"));

		Har har = server.getHar();
		String strFilePath = "test.har";
		FileOutputStream fos = new FileOutputStream(strFilePath);
		har.writeTo(fos);

	}

	catch(Exception ex) {

		System.out.println(ex.toString());

	}
	finally {

		server.stop();
		driver.close();
		driver.quit();
	}
}
private static String getIPOfNode(RemoteWebDriver remoteDriver)
{
	String hostFound = null;
	try  {
		HttpCommandExecutor ce = (HttpCommandExecutor) remoteDriver.getCommandExecutor();
		String hostName = ce.getAddressOfRemoteServer().getHost();
		int port = ce.getAddressOfRemoteServer().getPort();
		HttpHost host = new HttpHost(hostName, port);
		DefaultHttpClient client = new DefaultHttpClient();
		URL sessionURL = new URL(String.format("http://%s:%d/grid/api/testsession?session=%s", hostName, port, remoteDriver.getSessionId()));
		BasicHttpEntityEnclosingRequest r = new BasicHttpEntityEnclosingRequest( "POST", sessionURL.toExternalForm());
		HttpResponse response = client.execute(host, r);
		JSONObject object = extractObject(response);
		URL myURL = new URL(object.getString("proxyId"));
		if ((myURL.getHost() != null) && (myURL.getPort() != -1)) {
			hostFound = myURL.getHost();
		}
	} catch (Exception e) {
		System.err.println(e);
	}
	return hostFound;
}

private static JSONObject extractObject(HttpResponse resp) throws IOException, JSONException {
	InputStream contents = resp.getEntity().getContent();
	StringWriter writer = new StringWriter();
	IOUtils.copy(contents, writer, "UTF8");
	JSONObject objToReturn = new JSONObject(writer.toString());
	return objToReturn;
}
}


