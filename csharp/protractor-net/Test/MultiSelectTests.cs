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

// tests of Native AngularJS multiselect directive https://github.com/amitava82/angular-multiselect

namespace Protractor.Test
{
    [TestFixture]
    public class MultiSelectTests
    {
        private StringBuilder _verificationErrors = new StringBuilder();
        private IWebDriver _driver;
        private NgWebDriver _ngDriver;
        private WebDriverWait _wait;
        private const int _wait_seconds = 3;
        private String _base_url = "http://amitava82.github.io/angular-multiselect/";

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
        public void ShouldSelectOneByOne()
        {
        	// Given selecting cars in multuselect directive
            NgWebElement ng_directive_selector = _ngDriver.FindElement(NgBy.Model("selectedCar"));
            Assert.IsNotNull(ng_directive_selector.WrappedElement);
            IWebElement toggleSelect = ng_directive_selector.FindElement(By.CssSelector("button[ng-click='toggleSelect()']"));
            Assert.IsNotNull(toggleSelect);
            Assert.IsTrue(toggleSelect.Displayed);
            toggleSelect.Click();
            // When selecting all carscount one car at a time
            // find how many cars there are
            ReadOnlyCollection<NgWebElement> cars = ng_directive_selector.FindElements(NgBy.Repeater("i in items"));
            int cars_count = cars.Count(car => Regex.IsMatch(car.Text, "(?i:Audi|BMW)"));
            // select one car at a time
            for (int count = 0; count < cars_count; count++)
            {
                NgWebElement next_car = ng_directive_selector.FindElement(NgBy.Repeaterelement("i in items", count, "i.label"));
                StringAssert.IsMatch(@"(?i:Audi|BMW)", next_car.Text);
                Console.Error.WriteLine(next_car.Text);
                _ngDriver.Highlight(next_car);
                next_car.Click();
                // NOTE: the following does not work:
                // ms-selected ="There are {{selectedCar.length}}	                                                             
                // NgWebElement ng_button = new NgWebElement(ngDriver, button);
                // NgWebElement ng_length = ng_button.FindElement(NgBy.Binding("selectedCar.length"));
            }
            // TODO: Then button text shows that all cars were selected
            IWebElement button = _driver.FindElement(By.CssSelector("am-multiselect > div > button"));
            StringAssert.IsMatch(@"There are (\d+) car\(s\) selected", button.Text);
            Console.Error.WriteLine(button.Text);
        }

        [Test]
        public void ShouldSelectAll()
        {
        	// Given selecting cars in multuselect directive
            NgWebElement ng_directive_selector = _ngDriver.FindElement(NgBy.Model("selectedCar"));
            Assert.IsNotNull(ng_directive_selector.WrappedElement);
            Console.Error.WriteLine(ng_directive_selector.GetAttribute("innerHTML"));
            IWebElement toggleSelect = ng_directive_selector.FindElement(By.CssSelector("button[ng-click='toggleSelect()']"));
            Assert.IsNotNull(toggleSelect);
            Assert.IsTrue(toggleSelect.Displayed);
            toggleSelect.Click();
            // When selected all cars using 'check all' link
            _wait.Until(d => (d.FindElements(By.CssSelector("button[ng-click='checkAll()']")).Count != 0));
            IWebElement check_all = ng_directive_selector.FindElement(By.CssSelector("button[ng-click='checkAll()']"));
            Assert.IsNotNull(check_all);
            Assert.IsTrue(check_all.Displayed);
            check_all.Click();
            // Then all cars were selected
            ReadOnlyCollection<NgWebElement> cars = ng_directive_selector.FindElements(NgBy.Repeater("i in items"));
            Assert.AreEqual(cars.Count(), cars.Count(car => (Boolean) car.Evaluate("i.checked")));
        }
    }
}