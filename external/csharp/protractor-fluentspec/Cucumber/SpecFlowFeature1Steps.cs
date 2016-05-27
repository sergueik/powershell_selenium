using System;
using TechTalk.SpecFlow;
using OpenQA.Selenium;
using Protractor;
using FluentAssertions;
using NUnit.Framework;
using OpenQA.Selenium.Chrome;
using System.Linq;

namespace Cucumber
    {
    //Make extension method Click + WaitForAngular?
    [Binding]

    public class SpecFlowFeature1Steps
        {

        private IWebDriver _driver;
        private NgWebDriver _ngDriver;

        [BeforeScenario]
        public void Setup()
            {
            _driver = new ChromeDriver();
            //Make sure to WaitForAngular() so no async
            _ngDriver = new NgWebDriver(_driver) {IgnoreSynchronization = false};
            _ngDriver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
            }

        [AfterScenario]
        public void TearDown()
            {
            _driver.Quit();
            }

        [Given]
        public void Given_I_am_on_the_URL_P0(string homePage)
            {
            //Go to URL and verify address
            _ngDriver.Navigate().GoToUrl(@"https://" + homePage);
            _ngDriver.Url.ShouldBeEquivalentTo(@"https://" + homePage.Remove(0, 4) + @"/");
            }

        [Given]
        public void Given_I_have_entered_P0_into_the_search_bar(string city)
            {
            //Send city to search box and set active
            var search = _ngDriver.FindElement(By.XPath("//input[@name='search']"));
            search.SendKeys(city);
            search.Click();
            _ngDriver.WaitForAngular();

            //Verify Selected Element is Correct, if not select
            if (_ngDriver.FindElement(NgBy.Binding("getPresName($index)")).Text.ToLower() !=
                city.ToLower())
                {
                _ngDriver.FindElements(NgBy.Repeater("item in results | limitTo:10")).
                          First(x => x.Text == city).Click();
                }

            }

        [When("I search by clicking the magnifying glass")]
        public void WhenISearchByClickingTheMagnifyingGlass()
            {
            //Xpath verifies valid city selected
            //++ Click to next page
            _ngDriver.FindElement(By.XPath("//div[contains(@data-ng-if,'!hideSearchIcon')]")).Click();
            _ngDriver.WaitForAngular();
            }

        [Then]
        public void Then_I_should_be_taken_to_the_weather_page_for_P0(string city)
            {
            //Assert Page loaded is correct
            _ngDriver.FindElement(NgBy.Binding("locationTitle")).Click();
            Assert.IsTrue
                 (_ngDriver.FindElement(NgBy.Binding("locationTitle")).Text.ToLower().Trim()
                         .Contains
                             (city.ToLower().Trim()));
            }

        [Then]
        public void Then_the_temperature_should_be_between_P0_and_P1(int tempMin, int tempMax)
            {
            
            var temp = int.Parse(_ngDriver.FindElement(NgBy.Binding("temp | safeDisplay")).Text);
            //Assert current temp is in valid range
            Assert.IsTrue(temp
                 >= tempMin && temp <= tempMax);
            }
        }
    }
