using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.PhantomJS;
using System.Collections.ObjectModel;
using System.IO;
namespace Protractor.Test
{

    [TestFixture]
    public class Way2AutomationTests
    {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private String login_url = "http://way2automation.com/way2auto_jquery/index.php";
        private String base_url = "http://www.way2automation.com/angularjs-protractor/banking";
        [TestFixtureSetUp]
        public void SetUp()
        {
            // driver = new PhantomJSDriver();
            driver = new FirefoxDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
            ngDriver = new NgWebDriver(driver);
        }

        [SetUp]
        public void LogintToWay2AutomationSite()
        {
            const string signup_css_selector = "div#load_box.popupbox form#load_form a.fancybox[href='#login']";
            const string login_username_css_selector = "div#login.popupbox form#load_form input[name='username']";
            const string login_password_css_selector = "div#login.popupbox form#load_form input[type='password'][name='password']";
            const string login_button_css_selector = "div#login.popupbox form#load_form [value='Submit']";
            string username = "sergueik";
            string password = "i011155";
            Actions actions = new Actions(driver);

            driver.Navigate().GoToUrl(login_url);

            var signup_element = driver.FindElement(By.CssSelector(signup_css_selector));
            actions.MoveToElement(signup_element).Build().Perform();
            highlight(signup_element);
            signup_element.Click();

            var login_username = driver.FindElement(By.CssSelector(login_username_css_selector));
            highlight(login_username);
            login_username.SendKeys(username);

            var login_password_element = driver.FindElement(By.CssSelector(login_password_css_selector));
            highlight(signup_element);
            login_password_element.SendKeys(password);

            var login_button_element = driver.FindElement(By.CssSelector(login_button_css_selector));
            actions.MoveToElement(login_button_element).Build().Perform();
            highlight(login_button_element);
            login_button_element.Click();
            driver.Navigate().GoToUrl(base_url);
            ngDriver.Url = driver.Url;
        }

        [TestFixtureTearDown]
        public void TearDown()
        {
            try
            {
                driver.Close();
                driver.Quit();
            }
            catch (Exception) { } /* Ignore cleanup errors */
            Assert.IsEmpty(verificationErrors.ToString());
        }

        [Test]
        public void ShouldFindBankManagerLoginButton()
        {
            NgWebElement ng_login_button_element = ngDriver.FindElement(NgBy.ButtonText("Bank Manager Login"));
            StringAssert.IsMatch("Bank Manager Login", ng_login_button_element.Text);
        }

        [Test]
        public void ShouldFindCustomersButton()
        {
            NgWebElement ng_login_button_element = ngDriver.FindElement(NgBy.ButtonText("Bank Manager Login"));
            ng_login_button_element.Click();
            NgWebElement ng_customers_button_element = ngDriver.FindElement(NgBy.PartialButtonText("Customers"));
            StringAssert.IsMatch("Customers", ng_customers_button_element.Text);
            
        }
        
        
        public void highlight(IWebElement element, int px = 3, string color = "yellow")
        {
            ((IJavaScriptExecutor)driver).ExecuteScript("arguments[0].style.border='" + px + "px solid " + color + "'", element);
        }
    }
}
