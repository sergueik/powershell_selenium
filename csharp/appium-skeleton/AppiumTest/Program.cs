using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

using NUnit.Framework;

using OpenQA.Selenium;
using OpenQA.Selenium.Appium;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Appium.Android;
using OpenQA.Selenium.Appium.Interfaces;
using OpenQA.Selenium.Appium.MultiTouch;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Appium.Enums;
using Microsoft.Activities.UnitTesting;


namespace AppiumTest
{
    class Program
    {
        private static TimeSpan INIT_TIMEOUT_SEC = TimeSpan.FromSeconds(180); /* Change this to a more reasonable value */
        private static TimeSpan IMPLICIT_TIMEOUT_SEC = TimeSpan.FromSeconds(10); /* Change this to a more reasonable value */
        private static string appName = "chrome.apk";
        private static IWebDriver driver; 
        static void Main(string[] args)
        {
  	string appFolderPath = Directory.GetCurrentDirectory();
            string appPath = String.Format(@"{0}\\{1}", appFolderPath,appName );
        	

            DesiredCapabilities capabilities = new DesiredCapabilities();
            capabilities.SetCapability(CapabilityType.BrowserName, String.Empty);
            capabilities.SetCapability(CapabilityType.BrowserName, "");
            capabilities.SetCapability("platformName", "Android");
            capabilities.SetCapability("browserName", "chrome");
            //capabilities.SetCapability("udid", "test");  
            capabilities.SetCapability("app", appPath);
            capabilities.SetCapability(MobileCapabilityType.DeviceName, "Android Emulator");
            // https://groups.google.com/forum/#!topic/appium-discuss/Ey-yQBuo_OY
            // https://discuss.appium.io/t/appium-configuration/727
            // http://stackoverflow.com/questions/28637796/how-to-integrate-appium-with-c
                        capabilities.SetCapability("app-package", "com.android.chrome");
            capabilities.SetCapability("app-activity", "com.google.android.apps.chrome.Main");

            	driver = new AndroidDriver(new Uri("http://localhost:4723/wd/hub"), capabilities,INIT_TIMEOUT_SEC);

            Thread.Sleep(3000);
            driver.Navigate().GoToUrl("http://m.ctrip.com");
            Thread.Sleep(3000);
            driver.FindElement(By.XPath("//li[@class=\"f\"]")).Click();
            Thread.Sleep(3000);
            driver.FindElement(By.XPath("//button[@id=\"searchlistsubmit88888888\"]")).Click();
            Thread.Sleep(3000);

            driver.Quit();
        }
    }
}
