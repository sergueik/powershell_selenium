using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using System.Collections.ObjectModel;
using System.Collections;

// origin: https://github.com/anthonychu/Protractor-Net-Demo/tree/master/Protractor-Net-Demo

namespace Protractor.Test
{
    [TestFixture]
    public class CalculatorTests
    {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private String base_url = "http://juliemr.github.io/protractor-demo/";

        [TestFixtureSetUp]
        public void SetUp()
        {
            driver = new PhantomJSDriver();
            // driver = new FirefoxDriver();
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



        [Test]
        public void ShouldSetUrl()
        {
            ngDriver.Url = base_url;
            StringAssert.AreEqualIgnoringCase(ngDriver.Title, "Super Calculator");
        }

        [Test]
        public void ShouldFindModel()
        {
            ngDriver.Navigate().GoToUrl(base_url);
            IWebElement element = ngDriver.FindElement(NgBy.Model("first"));
            Assert.IsTrue(((NgWebElement)element).Displayed);
        }

        [Test]
        public void ShouldFindByOptions()
        {
            ngDriver.Navigate().GoToUrl(base_url);
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Options("value for (key, value) in operators"));
            Assert.AreEqual(((NgWebElement)elements[0]).Text, "+");
        }

        [Test]
        public void ShouldFindBySelectedOption()
        {
            ngDriver.Navigate().GoToUrl(base_url);
            IWebElement element = ngDriver.FindElement(NgBy.SelectedOption("operator"));
            Assert.AreEqual(((NgWebElement)element).Text, "+");
        }

        [Test]
        public void ShouldFindButtonText()
        {
            ngDriver.Navigate().GoToUrl(base_url);
            IWebElement element = ngDriver.FindElement(NgBy.ButtonText("Go!"));
            Assert.IsTrue(((NgWebElement)element).Displayed);
        }

        [Test]
        public void ShouldFindPartialButtonText()
        {
            ngDriver.Navigate().GoToUrl(base_url);
            IWebElement element = ngDriver.FindElement(NgBy.PartialButtonText("Go"));
            Assert.IsTrue(((NgWebElement)element).Displayed);
        }

        [Test]
        public void ShouldAdd()
        {
            ngDriver.Navigate().GoToUrl(base_url);
            
            var first = ngDriver.FindElement(NgBy.Input("first"));
            first.SendKeys("1");
            
            var second = ngDriver.FindElement(NgBy.Input("second"));
            second.SendKeys("2");

            NgWebElement math_operator = ngDriver.FindElement(NgBy.Options("value for (key, value) in operators"));
            Assert.AreEqual(math_operator.Text, "+");

            var goButton = ngDriver.FindElement(By.Id("gobutton"));
            goButton.Click();
            
            var result = ngDriver.FindElement(NgBy.Binding("latest")).Text;
            Assert.AreEqual("3", result);
        }
        
        [Test]
        public void ShouldSubstract()
        {
            ngDriver.Navigate().GoToUrl(base_url);
            
            var first = ngDriver.FindElement(NgBy.Input("first"));
            first.SendKeys("10");
            
            var second = ngDriver.FindElement(NgBy.Input("second"));
            second.SendKeys("2");

            ReadOnlyCollection<NgWebElement> math_operators = ngDriver.FindElements(NgBy.Options("value for (key, value) in operators"));

            var math_operators_enumerator = math_operators.GetEnumerator();
            math_operators_enumerator.Reset();
            while (math_operators_enumerator.MoveNext())
            {
                NgWebElement math_operator = (NgWebElement)math_operators_enumerator.Current;
                if (math_operator.Text.Equals("-", StringComparison.Ordinal))
                {
                    math_operator.Click();
                }
            }

            var goButton = ngDriver.FindElement(By.Id("gobutton"));
            goButton.Click();
            var result = ngDriver.FindElement(NgBy.Binding("latest")).Text;
            Assert.AreEqual("8", result);
        }

    }
}
