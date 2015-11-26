using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.PhantomJS;
using System.Collections.ObjectModel;

namespace Protractor.Test
{

	[TestFixture]
    public class NgNavTests
    {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private String base_url = "http://www.java2s.com/Tutorials/AngularJSDemo/n/ng_repeat_start_and_ng_repeat_end_example.htm";

        [TestFixtureSetUp]
        public void SetUp()
        {
            // driver = new FirefoxDriver();
            driver = new PhantomJSDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
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
            Assert.IsEmpty(verificationErrors.ToString());
        }

        [Test]
        public void ShouldFindRows()
        {
            ngDriver.Navigate().GoToUrl(base_url);
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Repeater("definition in definitions"));
            Assert.IsTrue(elements[0].Displayed);
            StringAssert.AreEqualIgnoringCase(elements[0].Text, "Foo");
        }
        [Test]
        public void ShouldFindCells()
        {   
            ngDriver.Navigate().GoToUrl(base_url);
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.RepeaterColumn("definition in definitions", "definition.text"));
            Assert.AreEqual(elements.Count, 2);
            StringAssert.IsMatch("Lorem ipsum", elements[0].Text );
             }
        
        [Test]
        public void ShouldFindTokens()
        {   
        	base_url  = "http://localhost/ng_table1.html";
            ngDriver.Navigate().GoToUrl(base_url);
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.RepeaterColumn("x in names", "Country"));
            Assert.AreNotEqual(0, elements.Count);
            StringAssert.IsMatch("Germany", elements[0].Text );
            StringAssert.IsMatch("Mexico", elements[1].Text );
            
             }
        
    }
}
