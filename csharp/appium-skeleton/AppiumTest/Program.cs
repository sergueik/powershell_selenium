using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using OpenQA.Selenium;

using OpenQA.Selenium.Appium;
using OpenQA.Selenium.Appium.Android;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Appium.Interfaces;
using OpenQA.Selenium.Appium.MultiTouch;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Appium.Enums;
using Microsoft.Activities.UnitTesting;
using NUnit.Framework;

namespace AppiumTest
{
    class Program
    {
        private static TimeSpan INIT_TIMEOUT_SEC = TimeSpan.FromSeconds(180); /* Change this to a more reasonable value */
        private static TimeSpan IMPLICIT_TIMEOUT_SEC = TimeSpan.FromSeconds(10); /* Change this to a more reasonable value */
        
        private static IWebDriver driver; 
        static void Main(string[] args)
        {

            DesiredCapabilities capabilities = new DesiredCapabilities();
            capabilities.SetCapability(CapabilityType.BrowserName, String.Empty);

            capabilities.SetCapability(MobileCapabilityType.AppiumVersion, "1.0");
            capabilities.SetCapability(MobileCapabilityType.PlatformVersion, "4.4.2");// unused
            // capabilities.SetCapability("device", "Android");
            capabilities.SetCapability(MobileCapabilityType.PlatformName, "Android");
            // capabilities.Platform = TestCapabilities.DevicePlatform.Android;
            capabilities.SetCapability(MobileCapabilityType.DeviceName, "Android Emulator");
            // https://groups.google.com/forum/#!topic/appium-discuss/Ey-yQBuo_OY
            // https://discuss.appium.io/t/appium-configuration/727
            // http://stackoverflow.com/questions/28637796/how-to-integrate-appium-with-c
            
            try {
            	driver = new AndroidDriver(new Uri("http://localhost:4723/wd/hub"), capabilities,INIT_TIMEOUT_SEC);
            
        } catch (Exception) {

        }
           //  driver.Manage().Timeouts().ImplicitlyWait(IMPLICIT_TIMEOUT_SEC);

            IWebElement qStr = ((IWebDriver)driver).FindElement(OpenQA.Selenium.By.Id("org.mozilla.firefox_beta:id/address_bar_bg"));
            qStr.Click();
            qStr.SendKeys("http://putlocker.is");
            IWebElement qButton = ((IWebDriver)driver).FindElement(OpenQA.Selenium.By.Id("org.mozilla.firefox_beta:id/awesomebar_button"));
            qButton.Click();
            Thread.Sleep(2000);
            driver.Close();
            driver.Quit();
        }
    }
}
