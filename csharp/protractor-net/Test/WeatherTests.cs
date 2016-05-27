using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using System.Collections.ObjectModel;
using System.Collections;
using System.Threading;
using System.Linq;
using Protractor.Extensions;
//using System.Drawing;
//using System.Windows.Forms;


namespace Protractor.Test
{
    [TestFixture]
    public class WeatherTests
    {
        private StringBuilder _verificationErrors = new StringBuilder();
        private IWebDriver _driver;
        private NgWebDriver _ngDriver;
        private String _base_url = "https://weather.com/";
        private WebDriverWait _wait;
        private const int _wait_seconds = 3;
        private const long _wait_poll_milliseconds = 300;

        [TestFixtureSetUp]
        public void SetUp()
        {
            _driver = new ChromeDriver();
            _driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
            // driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
            _ngDriver = new NgWebDriver(_driver);
            _ngDriver.Navigate().GoToUrl(_base_url);
            _wait = new WebDriverWait(_driver, TimeSpan.FromSeconds(_wait_seconds));
            _wait.PollingInterval = TimeSpan.FromMilliseconds(_wait_poll_milliseconds);
        }

        [TestFixtureTearDown]
        public void TearDown()
        {
            try
            {
                _driver.Quit();
            }
            catch (Exception) { } /* Ignore cleanup errors */
            Assert.AreEqual("", _verificationErrors.ToString());
        }


        [Test]
        public void ShouldSearchCitySuggestions()
        {

            String city = "Jacksonville, FL";
            _wait.Until(ExpectedConditions.ElementIsVisible(NgBy.Model("term")));
            IWebElement search = _driver.FindElement(By.XPath("//input[@name='search']"));
            Assert.IsNotNull(search);
            _ngDriver.Highlight(search);

            // NOTE: occasionally dropping first letter .
            // search.SendKeys(city[0].ToString());
            foreach (char cityChar in city.ToCharArray())
            {
                Console.Error.WriteLine("Sending: {0}", cityChar);
                search.SendKeys(cityChar.ToString());
                Thread.Sleep(50);

            }
            search.Click();
            ReadOnlyCollection<NgWebElement> ng_elements = _ngDriver.FindElements(NgBy.Repeater("item in results | limitTo:10"));
            foreach (NgWebElement ng_element in ng_elements)
            {
                try
                {
                    Assert.IsNotNull(ng_element.FindElement(NgBy.Binding("getPresName($index)")));
                    Console.Error.WriteLine("Suggested: {0}", ng_element.Text);

                }
                catch (StaleElementReferenceException e) { }
            }
            NgWebElement ng_firstMatchingElement = ng_elements.First(x => x.Text.ToLower() == city.ToLower());
            Assert.IsNotNull(ng_firstMatchingElement);
            _ngDriver.Highlight(ng_firstMatchingElement);
            Console.Error.WriteLine("Clicking: {0}", ng_firstMatchingElement.Text);

            ng_firstMatchingElement.Click();
            Thread.Sleep(1000);

            // TODO: Assert the change of the URL
        }
    }
}