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
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private String base_url = "https://weather.com/";
        private WebDriverWait wait;
        private const int wait_seconds = 3;

        [TestFixtureSetUp]
        public void SetUp()
        {
            driver = new ChromeDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
            // driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
            ngDriver = new NgWebDriver(driver);
            ngDriver.Navigate().GoToUrl(base_url);
            wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
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
        public void ShouldSearchCitySuggestions()
        {

            String city = "Jacksonville, FL";
            // var search = ngDriver.FindElement(By.XPath("//input[@name='search']"));
            wait.Until(ExpectedConditions.ElementIsVisible(NgBy.Model("term")));
            var search = ngDriver.FindElement(NgBy.Model("term"));
            Thread.Sleep(100);

            // NOTE: occasionally dropping first letter .
            // search.SendKeys(city[0].ToString());
            foreach (char cityChar in city.ToCharArray())
            {
                Console.Error.WriteLine("Sending: {0}", cityChar);
                search.SendKeys(cityChar.ToString());
                Thread.Sleep(50);

            }
            search.Click();
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Repeater("item in results | limitTo:10"));
            foreach (NgWebElement element in elements)
            {
                try
                {
                    // Console.Error.WriteLine("AccountNo: {0}", element.GetAttribute("innerHTML"));
                    NgWebElement check_element =
                       element.FindElement(NgBy.Binding("getPresName($index)"));
                    Assert.IsNotNull(check_element);
                    Console.Error.WriteLine("Suggested: {0}", element.Text);

                }
                catch (StaleElementReferenceException e) { }
            }
            elements.First(x => x.Text.ToLower() == city.ToLower()).Click();
            Thread.Sleep(1000);

            // TODO: Assert the change of the URL
        }
    }
}