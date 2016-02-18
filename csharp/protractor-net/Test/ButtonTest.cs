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
using OpenQA.Selenium.Support.UI;
using Protractor.Extensions;

namespace Protractor.Test
{

    [TestFixture]
    public class ButtonTest
    {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private String base_url = "http://kenhowardpdx.com/blog/2015/05/how-to-watch-scope-properties-in-angular-with-typescript/";

        [TestFixtureSetUp]
        public void SetUp()
        {
            driver = new ChromeDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
            driver.Navigate().GoToUrl(base_url);
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
        public void ShouldEvaluateIf()
        {
            IWebElement button = driver.FindElement(By.CssSelector("button.btn"));
            ngDriver = new NgWebDriver(driver);
            ngDriver.IgnoreSynchronization = true;
            ngDriver.IgnoreSynchronization = false;
            NgWebElement ng_button = new NgWebElement(ngDriver,button);
            Object state = ng_button.Evaluate("!house.frontDoor.isOpen");
            Assert.IsTrue(Convert.ToBoolean(state));
            StringAssert.IsMatch("house.frontDoor.open()", button.GetAttribute("ng-click"));
            StringAssert.IsMatch("Open Door", button.Text);
            button.Click();
            	
        }
        
   }
}