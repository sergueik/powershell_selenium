using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */

using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using EnableCommandSettings = OpenQA.Selenium.DevTools.V109.Page.EnableCommandSettings;
using SetGeolocationOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Emulation.SetGeolocationOverrideCommandSettings;
using SetLocaleOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Emulation.SetLocaleOverrideCommandSettings;
using Extensions;

// https://chromedevtools.github.io/devtools-protocol/tot/Emulation/#method-setGeolocationOverride
// https://chromedevtools.github.io/devtools-protocol/tot/Emulation/#method-clearGeolocationOverride
// https://chromedevtools.github.io/devtools-protocol/tot/Emulation/#method-setLocaleOverride
namespace Test {
	[TestFixture]
	public class SetGeolocationOverrideDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private const bool headless = false;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const String url = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private IWebElement element;
		
		[SetUp]
		public void setUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options);

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);		
			devTools = driver as IDevTools;
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
			domains.Page.Enable(new EnableCommandSettings());
		}

		// NOTE: should not annotate async, or test will hang
		[TearDown]
		public /* async */ void tearDown() {
			/* await */
			domains.Emulation.ClearGeolocationOverride();
			var localeSettings = new SetLocaleOverrideCommandSettings();
			localeSettings.Locale = null;
			/* await */
			domains.Emulation.SetLocaleOverride(localeSettings);
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public  /* async */  void test() {
			var localeSettings = new SetLocaleOverrideCommandSettings();
			localeSettings.Locale = "fr";
			/* await */
			domains.Emulation.SetLocaleOverride(localeSettings);
			var settings = new SetGeolocationOverrideCommandSettings();
			settings.Latitude = 51.509865;
			settings.Longitude = -0.118092;
			settings.Accuracy = 1;
			/* await */
			domains.Emulation.SetGeolocationOverride(settings);
				
			driver.Navigate().GoToUrl("https://maps.google.com");
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			// NOTE: browser needs to be visible for this element to be found
			element = driver.WaitUntilVisible(By.CssSelector("#mylocation #sVuEFc"));
			Assert.IsTrue(element.Displayed);
			element.Click();
			Thread.Sleep(3000);
		}
	}
}
