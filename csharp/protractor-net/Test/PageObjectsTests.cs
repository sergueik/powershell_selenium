using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Globalization;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;
using Protractor.Extensions;

namespace Protractor.Test{  

    /*
     * E2E testing against the AngularJS tutorial Step 5 sample: 
     * http://docs.angularjs.org/tutorial/step_05
     */
    [TestFixture]
    public class PageObjectsTests
    {
        private IWebDriver driver;
        private String base_url = "http://angular.github.io/angular-phonecat/step-5/app/";

        [SetUp]
        public void SetUp()
        {
            // Using NuGet Package 'PhantomJS'
            // driver = new PhantomJSDriver();
            driver = new ChromeDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
        }

        [TearDown]
        public void TearDown()
        {
            driver.Quit();
        }

        [Test(Description = "Should filter the phone list as user types into the search box")]
        public void ShouldFilter()
        {
            var step5Page = new TutorialStep5Page(driver, base_url );

            Assert.AreEqual(20, step5Page.GetResultsCount());

            step5Page.SearchFor("Motorola");
            Assert.AreEqual(8, step5Page.GetResultsCount());

            step5Page.SearchFor("Nexus");
            Assert.AreEqual(1, step5Page.GetResultsCount());
        }

        [Test(Description = "Should be possible to control phone order via the drop down select box")]
        public void ShouldSort()
        {
            var step5Page = new TutorialStep5Page(driver, "http://angular.github.io/angular-phonecat/step-5/app/");
            step5Page.SearchFor("tablet");
            Assert.AreEqual(2, step5Page.GetResultsCount());

            step5Page.SortByAge();
            Assert.AreEqual("Motorola XOOM™ with Wi-Fi", step5Page.GetResultsPhoneName(0));
            Assert.AreEqual("MOTOROLA XOOM™", step5Page.GetResultsPhoneName(1));

            step5Page.SortByName();
            Assert.AreEqual("MOTOROLA XOOM™", step5Page.GetResultsPhoneName(0));
            Assert.AreEqual("Motorola XOOM™ with Wi-Fi", step5Page.GetResultsPhoneName(1));
        }
    }
      /*
     * Page Object that represents the the AngularJS tutorial Step 5 page: 
     * http://docs.angularjs.org/tutorial/step_05
     */
    public class TutorialStep5Page
    {
        NgWebDriver ngDriver;

        public TutorialStep5Page(IWebDriver driver, string url)
        {
            ngDriver = new NgWebDriver(driver);
            ngDriver.Navigate().GoToUrl(url);
        }

        public TutorialStep5Page SearchFor(string query)
        {
            var q = ngDriver.FindElement(NgBy.Model("query"));
            q.Clear();
            q.SendKeys(query);
            return this;
        }

        public TutorialStep5Page SortByName()
        {
            // Alternative: Use OpenQA.Selenium.Support.UI.SelectElement from Selenium.Support package
            ngDriver
                .FindElement(NgBy.Model("orderProp"))
                .FindElement(By.XPath("//option[@value='name']"))
                .Click();
            return this;
        }

        public TutorialStep5Page SortByAge()
        {
            // Alternative: Use OpenQA.Selenium.Support.UI.SelectElement from Selenium.Support package
            ngDriver
                .FindElement(NgBy.Model("orderProp"))
                .FindElement(By.XPath("//option[@value='age']"))
                .Click();
            return this;
        }

        public int GetResultsCount()
        {
            return ngDriver.FindElements(NgBy.Repeater("phone in phones")).Count;
        }

        public string GetResultsPhoneName(int index)
        {
            return ngDriver.FindElements(NgBy.Repeater("phone in phones"))[index].Evaluate("phone.name") as string;
        }
    }

}
