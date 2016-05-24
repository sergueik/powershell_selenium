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
        public void ShouldSelectByOneCar()
        {
            NgWebElement ng_directive_selector = ngDriver.FindElement(NgBy.Model("selectedCar"));
            Assert.IsNotNull(ng_directive_selector.WrappedElement);
            // Console.Error.WriteLine(ng_directive_selector.GetAttribute("innerHTML"));
            IWebElement toggleSelect = ng_directive_selector.FindElement(By.CssSelector("button[ng-click='toggleSelect()']"));
            Assert.IsNotNull(toggleSelect);
            Assert.IsTrue(toggleSelect.Displayed);
            toggleSelect.Click();
            // count how many cars to select
            ReadOnlyCollection<NgWebElement> cars = ng_directive_selector.FindElements(NgBy.Repeater("i in items"));
            int cars_count = cars.Count(car => Regex.IsMatch(car.Text, "(?i:Audi|BMW|Honda)"));
            // select one car at a time
            for (int count = 0; count < cars_count; count++)
            {
                NgWebElement next_car = ng_directive_selector.FindElement(NgBy.Repeaterelement("i in items", count, "i.label"));
                StringAssert.IsMatch(@"(?i:Audi|BMW|Honda)", next_car.Text);
                Console.Error.WriteLine(next_car.Text);
                ngDriver.Highlight(next_car);
                next_car.Click();
                IWebElement button = driver.FindElement(By.CssSelector("am-multiselect > div > button"));
                StringAssert.IsMatch(@"There are (\d+) car\(s\) selected", button.Text);
                Console.Error.WriteLine(button.Text);
                // the following does not work:
                // ms-selected ="There are {{selectedCar.length}}	                                                             
                // NgWebElement ng_button = new NgWebElement(ngDriver, button);
                // NgWebElement ng_length = ng_button.FindElement(NgBy.Binding("selectedCar.length"));
            }
        }

        [Test]
        public void ShouldSelectAll()
        {
            NgWebElement ng_directive_selector = ngDriver.FindElement(NgBy.Model("selectedCar"));
            Assert.IsNotNull(ng_directive_selector.WrappedElement);
            Console.Error.WriteLine(ng_directive_selector.GetAttribute("innerHTML"));
            IWebElement toggleSelect = ng_directive_selector.FindElement(By.CssSelector("button[ng-click='toggleSelect()']"));
            Assert.IsNotNull(toggleSelect);
            Assert.IsTrue(toggleSelect.Displayed);
            toggleSelect.Click();
            // find 'check all' link
            wait.Until(d => (d.FindElements(By.CssSelector("button[ng-click='checkAll()']")).Count != 0));
            IWebElement check_all = ng_directive_selector.FindElement(By.CssSelector("button[ng-click='checkAll()']"));
            Assert.IsNotNull(check_all);
            Assert.IsTrue(check_all.Displayed);
            check_all.Click();
            // count how many cars were selected
            ReadOnlyCollection<NgWebElement> cars = ng_directive_selector.FindElements(NgBy.Repeater("i in items"));
            Assert.AreEqual(3, cars.Count(car => (Boolean) car.Evaluate("i.checked")));
            // Assert.AreEqual(3, cars.Count(car => Regex.IsMatch(car.Text, "(?i:Audi|BMW|Honda)")));
            // Console.Error.WriteLine(length.ToString());
        }
    }
}