using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Globalization;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.PageObjects;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using Protractor.Extensions;

namespace Protractor.Test
{

    [TestFixture]
    public class PageObjectsTests
    {
        private IWebDriver driver;
        private String base_url = "http://angular.github.io/angular-phonecat/step-6/app/";

        [SetUp]
        public void SetUp()
        {
            driver = new FirefoxDriver();
            // NOTE: SetScriptTimeout is obsolete
            driver.Manage().Timeouts().AsynchronousJavaScript =  TimeSpan.FromSeconds(5);
            // driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
        }

        [TearDown]
        public void TearDown()
        {
            driver.Quit();
        }

        [Test(Description = "Should filter the phone list as user types into the search box")]
        public void ShouldFilter()
        {
            var step6Page = new TutorialStep6Page(driver, base_url);

            Assert.AreEqual(3, step6Page.GetResultsCount());

            step6Page.SearchFor("Motorola");
            Assert.AreEqual(2, step6Page.GetResultsCount());

            step6Page.SearchFor("Nexus");
            Assert.AreEqual(1, step6Page.GetResultsCount());
        }

        [Test(Description = "Should be possible to control phone order via the drop down select box")]
        public void ShouldSort()
        {
            var step6Page = new TutorialStep6Page(driver, 
        	                                      "http://angular.github.io/angular-phonecat/step-6/app/");
            step6Page.SearchFor("tablet");
            Assert.AreEqual(2, step6Page.GetResultsCount());

            step6Page.SortByAge();
            Assert.AreEqual("Motorola XOOM™ with Wi-Fi", step6Page.GetResultsPhoneName(0));
            Assert.AreEqual("MOTOROLA XOOM™", step6Page.GetResultsPhoneName(1));

            step6Page.SortByName();
            Assert.AreEqual("MOTOROLA XOOM™", step6Page.GetResultsPhoneName(0));
            Assert.AreEqual("Motorola XOOM™ with Wi-Fi", step6Page.GetResultsPhoneName(1));
        }
	    }
    /*
   * Page Object that represents the the AngularJS tutorial Step  page: 
   * http://docs.angularjs.org/tutorial/step_06
   */
    public class TutorialStep6Page
    {
        NgWebDriver ngDriver;
        [FindsBy(How = How.Custom, CustomFinderType = typeof(NgByModel), Using = "$ctrl.query")]
        public IWebElement QueryInput { 
        	get; set; 
        }

        [FindsBy(How = How.Custom, CustomFinderType = typeof(NgByModel), Using = "$ctrl.orderProp")]
        public IWebElement SortBySelect { get; set; }
        public TutorialStep6Page(IWebDriver driver, string url)
        {
            ngDriver = new NgWebDriver(driver);
            PageFactory.InitElements(ngDriver, this);
            ngDriver.Navigate().GoToUrl(url);
        }

        public TutorialStep6Page SearchFor(string query)
        {
            QueryInput.Clear();
            QueryInput.SendKeys(query);
            return this;
        }

        public TutorialStep6Page SortByName()
        {
            SortBySelect.FindElement(By.XPath("//option[@value='name']")).Click();
            return this;
        }

        public TutorialStep6Page SortByAge()
        {
            SortBySelect.FindElement(By.XPath("//option[@value='age']")).Click();
            return this;
        }

        public int GetResultsCount()
        {
            return ngDriver.FindElements(NgBy.Repeater("phone in $ctrl.phones")).Count;
        }

        public string GetResultsPhoneName(int index)
        {
            return ngDriver.FindElements(NgBy.Repeater("phone in $ctrl.phones"))[index].Evaluate("phone.name") as string;
			// phone-list.template.html            
			//    {{phone.name}}
			//    {{phone.snippet}}

        }
    }

}
