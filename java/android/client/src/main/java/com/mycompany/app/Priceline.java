package com.mycompany.app;

import java.io.File;
import java.io.InputStream;
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
import org.openqa.selenium.android.AndroidDriver;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.WebElement;

import org.apache.http.message.BasicHttpEntityEnclosingRequest;
import  org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import org.openqa.selenium.By;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.remote.HttpCommandExecutor;
import org.openqa.selenium.remote.RemoteWebDriver;

import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.Keys;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.BindException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.charset.Charset;

public class Priceline
{  public static void main(String[] args) {

           WebDriver driver = new AndroidDriver();
           // driver.manage().timeouts().pageLoadTimeout(900, TimeUnit.SECONDS);
           try{
		   driver.get("http://www.priceline.com/");
/*
           String csspath_selector_1 = "a#btn_hotel";
		   WebElement element_1 = driver.findElement(By.cssSelector(csspath_selector_1));
		   System.out.println( element_1.getText());
		   new Actions(driver).moveToElement(element_1).click().build().perform();
                   element_1.click();
           Thread.sleep(5000);
*/
           }	

           catch(Exception ex) {

		   System.out.println(ex.toString());

	   }

           try{
           String xpath_2 = "//*[@id='btn_hotel']";
		   WebElement element_2 = driver.findElement(By.xpath(xpath_2));
		   System.out.println( element_2.getText());
		  // new Actions(driver).moveToElement(element_2).click().build().perform();
                   element_2.click();
           new Actions(driver).sendKeys(element_2,org.openqa.selenium.Keys.ENTER);
           Thread.sleep(5000);

           }	

           catch(Exception ex) {

		   System.out.println(ex.toString());

	   }


		  // driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		  // WebDriverWait wait = new WebDriverWait(driver, 30);

/*
	   try{
		   // wait.until(ExpectedConditions.elementToBeClickable(By.className("ccl-logo")));
		//   wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("ccl-logo")));
		   String value1 = "ddlDestinations";
		   String css_selector1 = String.format("select#%s", value1);
		   driver.findElement(By.cssSelector(css_selector1)).click();

	   }

	   catch(Exception ex) {

		   System.out.println(ex.toString());

	   }
*/
	   try{
		   //take a screenshot
		   File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);

		   //save the screenshot in png format on the disk.
		   FileUtils.copyFile(scrFile, new File(System.getProperty("user.dir") + "\\screenshot.png"));

	   }

	   catch(Exception ex) {

		   System.out.println(ex.toString());

	   }
	   finally {

		   driver.close();
		   driver.quit();
	   }
   }
}
