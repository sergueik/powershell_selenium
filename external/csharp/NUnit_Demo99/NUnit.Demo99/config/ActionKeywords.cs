using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using OpenQA.Selenium;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Support.UI;
using System.Configuration;
using System.Threading;
using System.Runtime.InteropServices;
using NUnit.Demo99.utility;
using RelevantCodes.ExtentReports;
using NUnit.Demo99.executionengine;

namespace NUnit.Demo99.config
{
    public class ActionKeywords
    {
        //ExcelUtils utils;
        public static IWebDriver driver;
        // This block of code will decide which browser type to open
        public static void openBrowser(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "Openning Browser");
                if (data == "Mozilla")
                {
                    driver = new FirefoxDriver();
                    Log._test.Log(LogStatus.Info, "Mozilla browser started");
                }
                else if (data == "IE")
                {
                    driver = new InternetExplorerDriver();
                    Log._test.Log(LogStatus.Info, "IE browser started");
                }
                else if (data == "Chrome")
                {
                    driver = new ChromeDriver();
                    Log._test.Log(LogStatus.Info, "Chrome browser started");
                }
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Failed to open Browser --- " + e.Message);
                DriverScript.bResult = false;
            }
        }

        public static void navigate(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "Navigating to URL: " + Constants.URL);
                driver.Manage().Timeouts().SetPageLoadTimeout(TimeSpan.FromSeconds(15));
                driver.Manage().Timeouts().ImplicitlyWait(TimeSpan.FromSeconds(15));
                driver.Navigate().GoToUrl(Constants.URL);
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Failed to navigate --- " + e.Message);
                DriverScript.bResult = false;
            }
        }

        public static void click(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "Clicking on web element: " + obj);

                // This is to fetch using the css selector of the element from the object Repository property file
                driver.FindElement(By.CssSelector(getKey(obj, ""))).Click();
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Unable to click --- " + e.Message);
                DriverScript.bResult = false;
            }
        }

        public static string getKey(String obj, String data)
        {
            return config.Settings.Default.Properties[obj].DefaultValue as string;
        }

        public static void input(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "Entering the text in " + obj);
                IWebElement we = driver.FindElement(By.CssSelector(getKey(obj, "")));
                we.Clear();
                we.SendKeys(data);
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Failed to enter text in " + obj + " --- " + e.Message);
                DriverScript.bResult = false;
                Console.WriteLine(e.Message);
            }
        }

        public static void waitFor(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "Wait for 5 seconds");
                Thread.Sleep(5000);
            }
            catch (ThreadInterruptedException e)
            {
                Log._test.Log(LogStatus.Info, "Unable to wait --- " + e.Message);
                DriverScript.bResult = false;
            }
        }

        public static void waitUntil(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "Wait until element " + obj + " is to be clickable");
                WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(10));
                wait.Until(ExpectedConditions.ElementToBeClickable(By.CssSelector(data)));
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Exception occurred in waiting --- " + e.Message);
                DriverScript.bResult = false;
            }
        }

        public static void checkCheckbox(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "make sure checkbox - Same as billing address - is checked");
                IWebElement chkbx = driver.FindElement(By.CssSelector(getKey(obj, "")));
                if (!chkbx.Selected)
                {
                    chkbx.Click();
                }
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Failed to check same as billing checkbox --- " + e.Message);
                DriverScript.bResult = false;
            }
        }

        public static void select(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "select a country from checkout page");
                SelectElement select = new SelectElement(driver.FindElement(By.CssSelector(getKey(obj, ""))));
                select.SelectByText(data);
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Failed to select from drop down list --- " + e.Message);
                DriverScript.bResult = false;
            }
        }

        public static void submitForm(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "pick the first form and submit - i.e. Click Add to Cart button");
                driver.FindElements(By.CssSelector(data))[0].Submit();
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Failed to add to cart --- " + e.Message);
                DriverScript.bResult = false;
            }
        }

        public static void confirmOrder(String obj, String data)
        {
            Log.getTest();
            Log._test.Log(LogStatus.Info, "confirm if order was placed successfully");
            // wait for seconds so as to load confirmation page		
            Thread.Sleep(8000);
            // take a screenshot anyway
            Log.TakeScreenshot(driver, Constants.Path_TestScr);
            Log._test.Log(LogStatus.Info, "Screenshot - " + Log._test.AddScreenCapture(Constants.Path_TestScr)); // add screenshot
            if (!driver.PageSource.Contains(data))
            {
                Log._test.Log(LogStatus.Info, "Failed to place the order --- ");
                DriverScript.bResult = false;
            }
        }

        public static void closeBrowser(String obj, String data)
        {
            try
            {
                Log.getTest();
                Log._test.Log(LogStatus.Info, "Closing the browser");
                driver.Quit();
            }
            catch (Exception e)
            {
                Log._test.Log(LogStatus.Info, "Failed to close browser --- " + e.Message);
                DriverScript.bResult = false;
            }
        }
    }
}
