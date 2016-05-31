using System;
using System.Text;
using System.Text.RegularExpressions;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using System.Collections.ObjectModel;
using System.Collections;
using System.Threading;
using System.Linq;
using Protractor.Extensions;
//using System.Drawing;
//using System.Windows.Forms;

// tests of Angular UI  DatePicker 
namespace Protractor.Test
{
    [TestFixture]
    public class DatePickerTests
    {
        private StringBuilder _verificationErrors = new StringBuilder();
        private IWebDriver _driver;
        private NgWebDriver _ngDriver;
        private WebDriverWait _wait;
        private const int _wait_seconds = 3;
        private String _base_url = "http://dalelotts.github.io/angular-bootstrap-datetimepicker/";

        [TestFixtureSetUp]
        public void SetUp()
        {
            _driver = new ChromeDriver();
            _driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
            // driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
            _ngDriver = new NgWebDriver(_driver);
            _wait = new WebDriverWait(_driver, TimeSpan.FromSeconds(_wait_seconds));
            _ngDriver.Navigate().GoToUrl(_base_url);
        }

        [Ignore("Ignore a test - only works in java version")]
        [Test]
        public void ShouldDirectSelectFromDatePicker()
        {

            NgWebElement ng_result = _ngDriver.FindElement(NgBy.Model("data.inputOnTimeSet", "[data-ng-app]"));
            ng_result.Clear();
            _ngDriver.Highlight(ng_result);
            IWebElement calendar = _ngDriver.FindElement(By.CssSelector(".input-group-addon"));
            _ngDriver.Highlight(calendar);
            Actions actions = new Actions(_ngDriver.WrappedDriver);
            actions.MoveToElement(calendar).Click().Build().Perform();

            int datepicker_width = 900;
            int datepicker_heght = 800;
            _driver.Manage().Window.Size = new System.Drawing.Size(datepicker_width, datepicker_heght);
            IWebElement dropdown = _driver.FindElement(By.CssSelector("div.dropdown.open ul.dropdown-menu"));
            NgWebElement ng_dropdown = new NgWebElement(_ngDriver, dropdown);
            Assert.IsNotNull(ng_dropdown);
            ReadOnlyCollection<NgWebElement> elements = ng_dropdown.FindElements(NgBy.Repeater("dateObject in week.dates"));
            Assert.IsTrue(28 <= elements.Count);

            String monthDate = "12";
            IWebElement dateElement = ng_dropdown.FindElements(NgBy.CssContainingText("td.ng-binding", monthDate)).First();
            Console.Error.WriteLine("Mondh Date: " + dateElement.Text);
            dateElement.Click();
            NgWebElement ng_element = ng_dropdown.FindElement(NgBy.Model("data.inputOnTimeSet", "[data-ng-app]"));
            Assert.IsNotNull(ng_element);
            _ngDriver.Highlight(ng_element);
            ReadOnlyCollection<NgWebElement> ng_dataDates = ng_element.FindElements(NgBy.Repeater("dateObject in data.dates"));
            Assert.AreEqual(24, ng_dataDates.Count);

            String timeOfDay = "6:00 PM";
            NgWebElement ng_hour = ng_element.FindElements(NgBy.CssContainingText("span.hour", timeOfDay)).First();
            Assert.IsNotNull(ng_hour);
            _ngDriver.Highlight(ng_hour);
            Console.Error.WriteLine("Hour of the day: " + ng_hour.Text);
            ng_hour.Click();
            String specificMinute = "6:35 PM";

            // reload
            // dropdown = _driver.FindElement(By.CssSelector("div.dropdown.open ul.dropdown-menu"));
            // ng_dropdown = new NgWebElement(_ngDriver, dropdown);
            ng_element = ng_dropdown.FindElement(NgBy.Model("data.inputOnTimeSet", "[data-ng-app]"));
            Assert.IsNotNull(ng_element);
            _ngDriver.Highlight(ng_element);
            NgWebElement ng_minute = ng_element.FindElements(NgBy.CssContainingText("span.minute", specificMinute)).First();
            Assert.IsNotNull(ng_minute);
            _ngDriver.Highlight(ng_minute);
            Console.Error.WriteLine("Time of the day: " + ng_minute.Text);
            ng_minute.Click();
            ng_result = _ngDriver.FindElement(NgBy.Model("data.inputOnTimeSet"));
            _ngDriver.Highlight(ng_result, 100);
            Console.Error.WriteLine("Selected Date/time: " + ng_result.GetAttribute("value"));

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

    }
}