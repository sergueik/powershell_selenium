using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.PhantomJS;
using System.Collections.ObjectModel;
using System.IO;
namespace Protractor.Test
{

    [TestFixture]
    public class OptionTests
    {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private String base_url = "http://milica.github.io/angular-selectbox/";
        private String testpage;
        
        [TestFixtureSetUp]
        public void SetUp()
        {
            driver = new PhantomJSDriver();
            // driver = new FirefoxDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
            ngDriver = new NgWebDriver(driver);
			ngDriver.Navigate().GoToUrl(base_url);

        }

        [TestFixtureTearDown]
        public void TearDown()
        {
            try
            {
                driver.Quit();
            }
            catch (Exception) { } /* Ignore cleanup errors */
            Assert.IsEmpty(verificationErrors.ToString());
        }

        [Test]
        public void ShouldFindFlatOptions()
        {
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Options("option in vm.options"));
            Assert.AreEqual(3, elements.Count);
            StringAssert.IsMatch("Apple", elements[0].Text);
            StringAssert.IsMatch("Pear", elements[1].Text);
        }

    }
}
