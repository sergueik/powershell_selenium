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
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private WebDriverWait wait;
        private const int wait_seconds = 3;
        private int highlight_timeout = 1000;
        private String base_url = "http://amitava82.github.io/angular-multiselect/";

        [TestFixtureSetUp]
        public void SetUp()
        {
            driver = new ChromeDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
            // driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
            ngDriver = new NgWebDriver(driver);
            wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
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
            Assert.AreEqual("", verificationErrors.ToString());
        }

        [Test]
        public void ShouldSelectOneByOne()
        {
            // Given multuselect directive
            NgWebElement ng_directive = ngDriver.FindElement(NgBy.Model("selectedCar"));
            Assert.IsNotNull(ng_directive.WrappedElement);
            // this is am-multiselect custom directive
            Assert.That(ng_directive.TagName, Is.EqualTo("am-multiselect"));
            // open am-multiselect
            IWebElement toggleSelect = ng_directive.FindElement(By.CssSelector("button[ng-click='toggleSelect()']"));
            Assert.IsNotNull(toggleSelect);
            Assert.IsTrue(toggleSelect.Displayed);
            toggleSelect.Click();

            // When I want to select every "Audi" or "BMW' car
            ReadOnlyCollection<NgWebElement> cars = ngDriver.FindElements(NgBy.Repeater("i in items"));
            int cars_count = cars.Count(car => Regex.IsMatch(car.Text, "(?i:Audi|BMW)"));
            // And I select one car at a time
            for (int count = 0; count < cars_count; count++)
            {
                NgWebElement next_car = ng_directive.FindElement(NgBy.Repeaterelement("i in items", count, "i.label"));
                StringAssert.IsMatch(@"(?i:Audi|BMW)", next_car.Text);
                Console.Error.WriteLine(next_car.Text);
                ngDriver.Highlight(next_car, highlight_timeout);
                next_car.Click();
            }
            // Then button text shows the total number of cars selected
            IWebElement button = driver.FindElement(By.CssSelector("am-multiselect > div > button"));
            ngDriver.Highlight(button, highlight_timeout);
            StringAssert.IsMatch(@"There are (\d+) car\(s\) selected", button.Text);
            int selected_cars_count = 0;
            int.TryParse(button.Text.FindMatch(@"(?<count>\d+)"), out selected_cars_count);

            Assert.AreEqual(cars_count, selected_cars_count);
            Console.Error.WriteLine("Button text: " + button.Text);

            try
            {
                // NOTE: the following does not work:
                // ms-selected ="There are {{selectedCar.length}}
                NgWebElement ng_button = new NgWebElement(ngDriver, button);
                // Console.Error.WriteLine(ng_button.GetAttribute("innerHTML"));
                NgWebElement ng_length = ng_button.FindElement(NgBy.Binding("selectedCar.length"));
                Console.Error.WriteLine(ng_length.Text);
            }
            catch (NullReferenceException)
            {
            }
        }

        [Test]
        public void ShouldSelectAll()
        {
            // Given selecting cars in multuselect directive
            NgWebElement ng_directive = ngDriver.FindElement(NgBy.Model("selectedCar"));
            // this is am-multiselect custom directive
            Assert.IsNotNull(ng_directive.WrappedElement);
            Assert.That(ng_directive.TagName, Is.EqualTo("am-multiselect"));
            // open am-multiselect
            
            IWebElement toggleSelect = ng_directive.FindElement(NgBy.ButtonText("Select Some Cars"));
            Assert.IsNotNull(toggleSelect);
            Assert.IsTrue(toggleSelect.Displayed);
            toggleSelect.Click();

            // When selected all cars using 'check all' link
            wait.Until(d => (d.FindElements(By.CssSelector("button[ng-click='checkAll()']")).Count != 0));
            IWebElement check_all = ng_directive.FindElement(By.CssSelector("button[ng-click='checkAll()']"));
            Assert.IsNotNull(check_all);
            Assert.IsTrue(check_all.Displayed);
            ngDriver.Highlight(check_all, highlight_timeout, 5, "blue");
            Thread.Sleep(1000);
            check_all.Click();
            // Then all cars were selected
            ReadOnlyCollection<NgWebElement> cars = ng_directive.FindElements(NgBy.Repeater("i in items"));
            Assert.AreEqual(cars.Count(), cars.Count(car => (Boolean)car.Evaluate("i.checked")));

            foreach (NgWebElement ng_check in ng_directive.FindElements(NgBy.RepeaterColumn("i in items", "i.label")))
            {
                if (Boolean.Parse(ng_check.Evaluate("i.checked").ToString()))
                {
                    IWebElement icon = ng_check.FindElement(By.ClassName("glyphicon"));
                    // <i class="glyphicon glyphicon-ok" ng-class="{'glyphicon-ok': i.checked, 'empty': !i.checked}"></i>
                    StringAssert.Contains("{'glyphicon-ok': i.checked, 'empty': !i.checked}", icon.GetAttribute("ng-class"));
                    ngDriver.Highlight(ng_check, highlight_timeout);
                }
            }
            Thread.Sleep(1000);

        }

        // TODO: filter
        // <input class="form-control placeholder="Filter" ng-model="searchText.label">

    }
}