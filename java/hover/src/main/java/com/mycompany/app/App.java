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
import org.openqa.selenium.WebElement;


import java.util.concurrent.TimeUnit;
import org.openqa.selenium.interactions.Actions;


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
import org.openqa.selenium.firefox.FirefoxProfile ;
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


static WebDriver driver;

  public static void main(String[] args) throws InterruptedException {
  
     // TODO Auto-generated method stub
     // Initialize WebDriver

// http://stackoverflow.com/questions/6787095/how-to-stop-selenium-from-creating-temporary-firefox-profiles-using-web-driver


// System.setProperty("webdriver.firefox.profile", "Selenium");
// WebDriver driver = new FirefoxDriver();

// String profilePath =  "c:\\Users\\sergueik\\AppData\\Roaming\\Mozilla\\Firefox\\Profiles\\nmkd7a04.Selenium" ;
//  profilePath =  "c:\\Users\\sergueik\\AppData\\Roaming\\Mozilla\\Firefox\\Profiles\\wfywwbuv.default" ;
// http://ted-gao.blogspot.com/2012/02/selenium-2-webdriver-and-firefox.html

// FirefoxProfile profile = new FirefoxProfile(new File(profilePath));                  
// WebDriver driver = new FirefoxDriver(profile);

       DesiredCapabilities capabilities = DesiredCapabilities.firefox();

capabilities =   new DesiredCapabilities("firefox", "", Platform.ANY);
FirefoxProfile profile = new ProfilesIni().getProfile("default");
capabilities.setCapability("firefox_profile", profile);
driver = new RemoteWebDriver(capabilities);
  
     // Wait For Page To Load
     driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);
  
     // Go to URL
     driver.get("http://www.myntra.com/");
  
     // Maximize Window
     driver.manage().window().maximize();
  
     // Mouse Over On " Men link " 
     Actions a1 = new Actions(driver);
     a1.moveToElement(driver.findElement(By.xpath("//a[@href='/shop/men?src=tn&nav_id=5']"))).build().perform();
     Thread.sleep(3000L);
  
     // Wait For Page To Load
     driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);
  
     // Click on " bags & backpacks " link
     driver.findElement(By.xpath("//a[@href='/men-bags-backpacks?src=tn&nav_id=25']")).click();
  
     // click on the categories - Bagpacks
     //  driver.findElement(By.xpath("//*[text()='Categories']//following::li[1]/label']")).click();
     // Hover on the 1st bag 
     Actions a2 = new Actions(driver);
     a2.moveToElement(driver.findElement(By.xpath("//ul[@class='results small']/li[1]"))).build().perform();
  
     //Click on the buy icon of the 1st bag
     driver.findElement(By.xpath(" //ul[@class='results small']/li[1]/div[1]//div[2]")).click();
  
     // Wait For Page To Load
     driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);
  
     // Hover over the shopping bag icon present on the top navigatinal bar   
     Actions a3 = new Actions(driver);
     a3.moveToElement(driver.findElement(By.xpath("//a[@href='/checkout/cart']"))).build().perform();
  
     // click on the remove icon
     driver.findElement(By.xpath("//a[@data-hint='Remove item']")).click();
  
     //closing current driver window 
     driver.close();   
    }

}


