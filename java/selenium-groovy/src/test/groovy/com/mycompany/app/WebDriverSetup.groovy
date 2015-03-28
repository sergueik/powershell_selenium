package com.mycompany.app

import java.io.File
import java.util.logging.Level

import org.apache.log4j.LogManager
import org.apache.log4j.Logger
import org.openqa.selenium.By
import org.openqa.selenium.WebDriver
import org.openqa.selenium.chrome.ChromeDriver
import org.openqa.selenium.chrome.ChromeDriverService
import org.openqa.selenium.firefox.FirefoxDriver
import org.openqa.selenium.firefox.FirefoxProfile
import org.openqa.selenium.firefox.internal.ProfilesIni
// import org.openqa.selenium.firefox.ProfileManager
import org.openqa.selenium.ie.InternetExplorerDriver
import org.openqa.selenium.logging.LoggingPreferences
import org.openqa.selenium.remote.DesiredCapabilities
import org.openqa.selenium.remote.RemoteWebDriver
import org.openqa.selenium.TakesScreenshot
import org.openqa.selenium.OutputType
import org.openqa.selenium.support.ui.ExpectedConditions
import org.openqa.selenium.support.ui.WebDriverWait
import org.openqa.selenium.logging.LogType
import org.openqa.selenium.remote.CapabilityType


import com.mycompany.app.utils.Utils
import com.opera.core.systems.OperaDriver


class WebDriverSetup {

	private static WebDriverSetup setup;
	protected static Logger logger = LogManager.getLogger(WebDriverSetup.class);
	protected WebDriver driver;
	protected Utils utils;
	protected String startUrl;
	protected String username;
	protected String password;

	public static WebDriverSetup getInstance() {
		if (setup == null) {
			setup = new WebDriverSetup();
		}
	}
	
	private WebDriverSetup() {
		startUrl = PropertyHolder.testProperties.getProperty("StartUrl");
		String browser = PropertyHolder.testProperties.getProperty("BrowserType");
		username = PropertyHolder.testProperties.getProperty("LoginUserName");
		password = PropertyHolder.testProperties.getProperty("LoginPassword");

		if (browser.equalsIgnoreCase("*firefox")) {
			driver = getFirefoxDriver();
			logger.info("Started firefox driver");
		}
		else if (browser.equalsIgnoreCase("*iexplore")) {
			driver = getIEDriver();
			logger.info("Started internetexplorer driver");
		}
		else if (browser.equalsIgnoreCase("*googlechrome")) {
			driver = getGoogleChromeDriver();
			logger.info("Started Googlechrome driver");
		}
		else if (browser.equalsIgnoreCase("*opera")) {
			driver = new OperaDriver();
			logger.info("Started opera driver");
		}

		/*  open the url */
		logger.info("Connecting to starturl: " + startUrl);
		driver.get(startUrl);
		logger.info("Connected to starturl");
		
		//utils.waitForElementPresent(By.id(SeleniumConstants.WHOLE_CONTENT_ID), 60);
	}

	private WebDriver getFirefoxDriver() {
		logger.info("Starting firefox driver");
		DesiredCapabilities caps = DesiredCapabilities.firefox(); 
		FirefoxProfile firefoxProfile = new FirefoxProfile();
		caps.setCapability(FirefoxDriver.PROFILE, firefoxProfile);
		
		//use setting in log4j to switch on logging of firefox driver
		Logger log4jLogger = LogManager.getLogger("org.openqa");
		if (log4jLogger.isInfoEnabled()) {
			LoggingPreferences logs = new LoggingPreferences(); 
			logs.enable(LogType.DRIVER, Level.INFO); 
			caps.setCapability(CapabilityType.LOGGING_PREFS, logs); 
			logger.info("Logging of firefox driver is enabled");
			String userDir = System.getProperty("user.dir"); 
			System.setProperty("webdriver.firefox.logfile", "target/firefox-console.log");
			System.setProperty("webdriver.log.file","${userDir}/target/firefox-driver.log");
		}

		//in pom specify whether firebug should be loaded or not
		boolean addFirebug = PropertyHolder.testProperties.getProperty("AddFirebugToFirefox").toBoolean();
		if (addFirebug == true) {
			logger.info("Adding firebug 1.9.1 extension");
			File file = new File("xpi/firebug-1.9.1-fx.xpi");
			firefoxProfile.addExtension(file);
			firefoxProfile.setPreference("extensions.firebug.currentVersion", "1.9.1");
		}
		
		//in pom specify whether to explicitly use native events or not
		String setNativeEventsProperty = PropertyHolder.testProperties.getProperty("SetNativeEvents");
		if (setNativeEventsProperty.equalsIgnoreCase("true") || setNativeEventsProperty.equalsIgnoreCase("false")) {
			boolean setNativeEvents = Boolean.valueOf(setNativeEventsProperty);
			logger.info("explicitly setting native events to explicit value of " + setNativeEvents);
			firefoxProfile.setEnableNativeEvents(setNativeEvents);
		}
		else {
			logger.debug("relying on default value for native events: " + firefoxProfile.areNativeEventsEnabled());
		}

//		WebDriver ffDriver = new FirefoxDriver(caps);
//		return ffDriver;
                RemoteWebDriver driver = new RemoteWebDriver(new URL("http://127.0.0.1:4444/wd/hub"), caps)
               return driver
	}



	private WebDriver getIEDriver() {
		logger.info("Starting iexplorer driver");
		DesiredCapabilities ieCapabilities = DesiredCapabilities.internetExplorer();
		ieCapabilities.setCapability(InternetExplorerDriver.INTRODUCE_FLAKINESS_BY_IGNORING_SECURITY_DOMAINS, true);
		InternetExplorerDriver ieDriver = new InternetExplorerDriver(ieCapabilities);
		return ieDriver;

	}

	private WebDriver getGoogleChromeDriver() {
		logger.info("Starting googlechrome driver");
		DesiredCapabilities chromeCapabilities = DesiredCapabilities.chrome();

		System.setProperty("webdriver.chrome.driver", PropertyHolder.testProperties.("ChromedriverPath"));

		ChromeDriverService service = new ChromeDriverService.Builder()
				.usingChromeDriverExecutable(new File(PropertyHolder.testProperties.("ChromedriverPath")))
				.usingAnyFreePort().build();

		logger.info("Starting chrome driver service..");
		service.start();

		WebDriver driverGC = new RemoteWebDriver(service.getUrl(),chromeCapabilities);
		return driverGC;
	}
	
	public void close() {
		logger.info("Closing driver now");
		driver.close();
	}
}
