using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using OpenQA.Selenium;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Safari;
using OpenQA.Selenium.PhantomJS;
using System.Net;
using SwdPageRecorder.WebDriver.JsCommand;

using System.Xml;
using HtmlAgilityPack;


namespace SwdPageRecorder.WebDriver.SwdBrowserUtils
{
    public static class WebDriverUtils
    {
        private static string path_to_binary;
        private static string path_to_driver;
        private static string binary_path_propery;
        private static string driver_path_propery;


        public static IWebDriver Initialize(WebDriverOptions browserOptions, out bool isRemote)
        {
            IWebDriver driver = null;
            if (browserOptions.IsRemote)
            {
                driver = ConnetctToRemoteWebDriver(browserOptions);
                isRemote = true;
            }
            else
            {
                driver = StartEmbededWebDriver(browserOptions);
                isRemote = false;
            }
            return driver;
        }

        private static IWebDriver ConnetctToRemoteWebDriver(WebDriverOptions browserOptions)
        {
            DesiredCapabilities caps = null;
            Uri hubUri = new Uri(browserOptions.RemoteUrl);

            switch (browserOptions.BrowserName)
            {

                /* 
                 http://stackoverflow.com/questions/17398896/how-to-use-different-version-of-firefox-using-webdriver
                 https://code.google.com/p/selenium/wiki/FirefoxDriver
                 https://code.google.com/p/selenium/wiki/InternetExplorerDriver
                 https://code.google.com/p/selenium/wiki/ChromeDriver#Overriding_the_Chrome_binary_location
 
                 */

                case WebDriverOptions.browser_Firefox:
                    path_to_binary = @"C:\Program Files\Mozilla Firefox\firefox.exe";
                    binary_path_propery = "webdriver.firefox.bin";
                    caps = DesiredCapabilities.Firefox();
                    break;
                case WebDriverOptions.browser_Chrome:
                    path_to_driver = @"C:\Program Files\Mozilla Firefox\firefox.exe";
                    driver_path_propery = "webdriver.chrome.driver";
                    caps = DesiredCapabilities.Chrome();
                    break;
                case WebDriverOptions.browser_InternetExplorer:
                    caps = DesiredCapabilities.InternetExplorer();
                    path_to_driver = @"C:\Program Files\Mozilla Firefox\firefox.exe";
                    driver_path_propery = "webdriver.ie.driver";
                    break;
                case WebDriverOptions.browser_PhantomJS:
                    caps = DesiredCapabilities.PhantomJS();
                    break;
                case WebDriverOptions.browser_HtmlUnit:
                    caps = DesiredCapabilities.HtmlUnit();
                    break;
                case WebDriverOptions.browser_HtmlUnitWithJavaScript:
                    caps = DesiredCapabilities.HtmlUnitWithJavaScript();
                    break;
                case WebDriverOptions.browser_Opera:
                    caps = DesiredCapabilities.Opera();
                    break;
                case WebDriverOptions.browser_Safari:
                    caps = DesiredCapabilities.Safari();
                    break;
                case WebDriverOptions.browser_IPhone:
                    caps = DesiredCapabilities.IPhone();
                    break;
                case WebDriverOptions.browser_IPad:
                    caps = DesiredCapabilities.IPad();
                    break;
                case WebDriverOptions.browser_Android:
                    caps = DesiredCapabilities.Android();
                    break;
                default:
                    throw new ArgumentException(String.Format(@"<{0}> was not recognized as supported browser. This parameter is case sensitive", browserOptions.BrowserName),
                                                "WebDriverOptions.BrowserName");
            }
            RemoteWebDriver newDriver = new RemoteWebDriver(hubUri, caps);
            return newDriver;
        }

        private static IWebDriver StartEmbededWebDriver(WebDriverOptions browserOptions)
        {
            switch (browserOptions.BrowserName)
            {

                case WebDriverOptions.browser_Firefox:
                    path_to_binary = @"C:\Program Files\Mozilla Firefox\firefox.exe";
                    binary_path_propery = "webdriver.firefox.bin";
                    FirefoxProfile profile = new FirefoxProfile();
                    profile.SetPreference(binary_path_propery, path_to_binary);
                    FirefoxBinary binary = new FirefoxBinary(path_to_binary);
                    //return new FirefoxDriver(profile);
                    return new FirefoxDriver(binary, profile);
                case WebDriverOptions.browser_Chrome:
                    return new ChromeDriver();
                case WebDriverOptions.browser_InternetExplorer:
                    return new InternetExplorerDriver();
                case WebDriverOptions.browser_PhantomJS:
                    return new PhantomJSDriver();
                case WebDriverOptions.browser_Safari:
                    return new SafariDriver();
                default:
                    throw new ArgumentException(String.Format(@"<{0}> was not recognized as supported browser. This parameter is case sensitive", browserOptions.BrowserName),
                                                "WebDriverOptions.BrowserName");
            }
        }
    }
}
