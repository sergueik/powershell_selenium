using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;

namespace Protractor.Test
{
    [TestFixture]
    public class ExceptionTests
    {
    	private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private String base_url = "http://www.google.com/";

    	[TestFixtureSetUp]
        public void SetUp()
        {
            driver = new PhantomJSDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
            ngDriver = new NgWebDriver(driver);
        }

        [TestFixtureTearDown]
        public void TearDown()
        {
            try
            {
                driver.Quit();
            }
            catch (Exception) { } /* Ignore cleanup errors */
            Assert.AreEqual("", verificationErrors.ToString());
        }

        // http://www.nunit.org/index.php?p=exceptionAsserts&r=2.5
        [Test]
        public void ShouldGetExceptionWaitForAngular()
        {
            Assert.Throws(typeof(OpenQA.Selenium.WebDriverTimeoutException),
              delegate { ngDriver.Navigate().GoToUrl(base_url); });

        }
    }
}