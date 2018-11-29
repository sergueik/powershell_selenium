using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using System.Collections.ObjectModel;
using System.IO;

namespace Protractor.Test {

    private bool headless = true;
    [TestFixture]
    public class OptionTests {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;
        private String base_url;
        private String testpage = "bind_select_option_data_from_array_example.htm";
        
        [TestFixtureSetUp]
        public void SetUp()
        {
	if (headless) { 
		var option = new ChromeOptions();
		option.AddArgument("--headless");
		driver = new ChromeDriver(option);
	} else {
		driver = new ChromeDriver();
	}
            // driver = new FirefoxDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
            ngDriver = new NgWebDriver(driver);
        }
        
        [SetUp]
        public void NavigateToTestPage(){
            base_url = new System.Uri(Path.Combine( Directory.GetCurrentDirectory(), testpage)).AbsoluteUri;
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
            Assert.IsEmpty(verificationErrors.ToString());
        }
        
//        [Test]
//        public void ShouldFindFlatOptions()
//        {
//        	base_url = "http://milica.github.io/angular-selectbox/";
//        	ngDriver.Navigate().GoToUrl(base_url);
//            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Options("option in vm.options"));
//            Assert.AreEqual(3, elements.Count);
//            StringAssert.IsMatch("Apple", elements[0].Text);
//            StringAssert.IsMatch("Pear", elements[1].Text);
//        }

        [Test]
        public void ShouldFindSelectedtOption()
        {            
            NgWebElement element = ngDriver.FindElement(NgBy.SelectedOption("myChoice"));
            StringAssert.IsMatch("three", element.Text);
        }

        [Test]
        public void ShouldChangeSelectedtOption()
        {            
        	ReadOnlyCollection<NgWebElement> options = ngDriver.FindElements(NgBy.Repeater("option in options"));
        	var options_enumerator = options.GetEnumerator();
            
        	options_enumerator.Reset();
            while (options_enumerator.MoveNext())
            {
                NgWebElement option = (NgWebElement)options_enumerator.Current;
                if (option.Text.Equals("two", StringComparison.Ordinal))
                {
                    option.Click();
                }
            }
            NgWebElement element = ngDriver.FindElement(NgBy.SelectedOption("myChoice"));
            StringAssert.IsMatch("two", element.Text);
        }
        
    }
}
