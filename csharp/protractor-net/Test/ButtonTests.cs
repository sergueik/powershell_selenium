using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;

using System.IO;
using System.Linq;
using System.Text;
using System.Threading;

using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using Protractor.Extensions;

// Tests of AngularJS Button embedded in nested iframe
namespace Protractor.Test
{
    [TestFixture]
    public class ButtonTests
    {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private WebDriverWait wait;
        private Actions actions;
        private IAlert alert;
        private string alert_text;

        private const int wait_seconds = 3;
        private const long wait_poll_milliseconds = 300;
        private String base_url = "http://kenhowardpdx.com/blog/2015/05/how-to-watch-scope-properties-in-angular-with-typescript/";
        private IWebDriver frame;

        private void GetPageContent(string testpage)
        {
            String base_url = new System.Uri(Path.Combine(Directory.GetCurrentDirectory(), testpage)).AbsoluteUri;
            ngDriver.Navigate().GoToUrl(base_url);
        }

        [TestFixtureSetUp]
        public void SetUp()
        {
            driver = new ChromeDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
            wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
            wait.PollingInterval = TimeSpan.FromMilliseconds(wait_poll_milliseconds);
            actions = new Actions(driver);

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
        public void Should_01_EvaluateIf()
        {
            driver.Navigate().GoToUrl(base_url);
            IWebElement frameElement = driver.FindElement(By.CssSelector("iframe[id='cp_embed_EjYzev']"));
            actions.MoveToElement(frameElement).Build().Perform();
            driver.Highlight(frameElement);
            var tmp = driver.SwitchTo().Frame(frameElement);
            frameElement = tmp.FindElement(By.XPath("//iframe[@id='result-iframe']"));
            frame = tmp.SwitchTo().Frame(frameElement);
            IWebElement button = frame.FindElement(By.CssSelector("button.btn"));
            ngDriver = new NgWebDriver(frame);
            ngDriver.IgnoreSynchronization = false;
            NgWebElement ng_button = new NgWebElement(ngDriver, button);
            Object state = ng_button.Evaluate("!house.frontDoor.isOpen");
            Assert.IsTrue(Convert.ToBoolean(state));
            StringAssert.IsMatch("house.frontDoor.open()", button.GetAttribute("ng-click"));
            StringAssert.IsMatch("Open Door", button.Text);
        }
        
		// TODO : test works correctly only in java
        [Test]
        public void Should_02_ClickButton()
        {
            driver.Navigate().GoToUrl(base_url);
            IWebElement frameElement = driver.FindElement(By.CssSelector("iframe[id='cp_embed_EjYzev']"));
            actions.MoveToElement(frameElement).Build().Perform();
            driver.Highlight(frameElement);
            var tmp = driver.SwitchTo().Frame(frameElement);
            frameElement = tmp.FindElement(By.XPath("//iframe[@id='result-iframe']"));
            frame = tmp.SwitchTo().Frame(frameElement);
            IWebElement button = frame.FindElement(By.CssSelector("button.btn"));
            frame.Highlight(button);
            // TODO: cannot click
            try
            {
                button.Click();
            }
            catch (InvalidOperationException e)
            {
                // NOTE: System.InvalidOperationException : unhandled inspector error: {"code":-32000,"message":"Can not access given context."}
            }

            try
            {
                tmp = frame.SwitchTo().DefaultContent();
                driver = tmp.SwitchTo().DefaultContent();
                alert = driver.SwitchTo().Alert();
                alert_text = alert.Text;
                Console.Error.WriteLine(alert_text);
                StringAssert.StartsWith("The door is open", alert_text);
                alert.Accept();
            }
            catch (NoAlertPresentException ex)
            {
                // Alert not present
                verificationErrors.Append(ex.StackTrace);
            }
            catch (WebDriverException ex)
            {
                // Alert not handled by PhantomJS
                verificationErrors.Append(ex.StackTrace);
            }
        }

    }
}