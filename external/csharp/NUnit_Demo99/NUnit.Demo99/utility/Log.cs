using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using RelevantCodes.ExtentReports;
using NUnit.Demo99.executionengine;
using OpenQA.Selenium;
using System.Drawing.Imaging;

namespace NUnit.Demo99.utility
{
    public class Log
    {
        public static ExtentReports _extent = new ExtentReports(config.Constants.Path_Report, DisplayOrder.NewestFirst);
        public static ExtentTest _test;
        public static DriverScript ds;
        public static void getTest()
        {
            if (_test == null)
            {
                // init extent reports instance
                _extent.LoadConfig(config.Constants.Path_Config);
                _test = _extent.StartTest("Practice Exercise", "This is the Practice Exercise");
            }
        }

        // this is to print log for the beginning of the test case, as we usually run so many test cases as a test suite
        public static void startTestCase(String sTestCaseName)
        {
            getTest();
            _test.Log(LogStatus.Info, "|-------------------------");
            _test.Log(LogStatus.Info, "Test ID: " + sTestCaseName);
        }

        //This is to print log for the ending of the test case
        public static void endTestCase(String sTestCaseName)
        {
            _test.Log(LogStatus.Info, "-E---N---D-");
            _test.Log(LogStatus.Info, "-------------------------|");
        }

        public static void TakeScreenshot(IWebDriver driver, string fileName)
        {
            ITakesScreenshot screenshotDriver = driver as ITakesScreenshot;
            if (screenshotDriver == null)
            {
                _test.Log(LogStatus.Fail, "Error in taking screenshot!");
            }
            else
            {
                Screenshot screenshot = screenshotDriver.GetScreenshot();
                screenshot.SaveAsFile(fileName, System.Drawing.Imaging.ImageFormat.Png);
            }
        }
    }
}
