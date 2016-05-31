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
	// http://kenhowardpdx.com/blog/2015/05/how-to-watch-scope-properties-in-angular-with-typescript/
    [TestFixture]
    public class ButtonTests
    {
        private StringBuilder _verificationErrors = new StringBuilder();
        private IWebDriver _driver;
        private NgWebDriver _ngDriver;
        private String _base_page = "ng_dropdown_watch.htm";

        private void GetPageContent(string testpage)
        {
            String base_url = new System.Uri(Path.Combine(Directory.GetCurrentDirectory(), testpage)).AbsoluteUri;
            _ngDriver.Navigate().GoToUrl(base_url);
        }

        [TestFixtureSetUp]
        public void SetUp()
        {
            // _driver = new ChromeDriver();
            _driver = new PhantomJSDriver();
            _driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
            GetPageContent(_base_page);
        }

        [TestFixtureTearDown]
        public void TearDown()
        {
            try
            {
                _driver.Quit();
            }
            catch (Exception) { } /* Ignore cleanup errors */
            Assert.IsEmpty(_verificationErrors.ToString());
        }
        [Test]
        public void ShouldEvaluateIf()
        {
            IWebElement button = _driver.FindElement(By.CssSelector("button.btn"));
            _ngDriver = new NgWebDriver(_driver);
            _ngDriver.IgnoreSynchronization = true;
            NgWebElement ng_button = new NgWebElement(_ngDriver,button);
            Object state = ng_button.Evaluate("!house.frontDoor.isOpen");
            Assert.IsTrue(Convert.ToBoolean(state));
            StringAssert.IsMatch("house.frontDoor.open()", button.GetAttribute("ng-click"));
            StringAssert.IsMatch("Open Door", button.Text);
            button.Click();
            	
        }
        
   }
}