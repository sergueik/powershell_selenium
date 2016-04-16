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
        public void Shouldcheck_allSelect()
        {

            NgWebElement ng_selected_car = ngDriver.FindElement(NgBy.Model("selectedCar"));
            Assert.IsNotNull(ng_selected_car.WrappedElement);
            Console.Error.WriteLine(ng_selected_car.GetAttribute("innerHTML"));
            IWebElement toggleSelect = ng_selected_car.FindElement(By.CssSelector("button[ng-click='toggleSelect()']"));
            Assert.IsNotNull(toggleSelect);
            Assert.IsTrue(toggleSelect.Displayed);
            toggleSelect.Click();

            // ngDriver.waitForAngular();
            wait.Until(d => (d.FindElements(By.CssSelector("button[ng-click='checkAll()']")).Count != 0));
            IWebElement check_all = ng_selected_car.FindElement(By.CssSelector("button[ng-click='checkAll()']"));
            Assert.IsNotNull(check_all);
            Assert.IsTrue(check_all.Displayed);

            NgWebElement ngcheck_all = new NgWebElement(ngDriver, check_all);
            ngcheck_all.Click();
            // ngDriver.waitForAngular();
            ReadOnlyCollection<NgWebElement> cars = ng_selected_car.FindElements(NgBy.Repeater("i in items"));
            Assert.AreEqual(3, cars.Count(car => Regex.IsMatch(car.Text, "(?i:Audi|BMW|Honda)")));
        }


    }
}