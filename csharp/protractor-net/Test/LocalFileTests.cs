using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.PhantomJS;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
namespace Protractor.Test
{

    [TestFixture]
    public class LocalFileTests
    {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private NgWebDriver ngDriver;

        private String testpage;

        [TestFixtureSetUp]
        public void SetUp()
        {
            driver = new PhantomJSDriver();
            // .net does not seem to allow running local files in the desktop browser
            // driver = new FirefoxDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
            ngDriver = new NgWebDriver(driver);
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
        private void GetPageContent(string testpage)
        {
            String base_url = new System.Uri(Path.Combine(Directory.GetCurrentDirectory(), testpage)).AbsoluteUri;
            ngDriver.Navigate().GoToUrl(base_url);

        }
        [Test]
        public void ShouldEvaluate()
        {
            GetPageContent("ng_service_example.htm");
            ReadOnlyCollection<NgWebElement> ng_people = ngDriver.FindElements(NgBy.Repeater("person in people"));
            var ng_people_enumerator = ng_people.GetEnumerator();
            ng_people_enumerator.Reset();
            while (ng_people_enumerator.MoveNext())
            {
                NgWebElement ng_person = (NgWebElement)ng_people_enumerator.Current;
                if (ng_person.Text == null)
                {
                    break;
                }
                NgWebElement ng_name = ng_person.FindElement(NgBy.Binding("person.Name"));
                Assert.IsNotNull(ng_name.WrappedElement);
                Object obj_country = ng_person.Evaluate("person.Country");
                Assert.IsNotNull(obj_country);
                if (String.Compare("Around the Horn", ng_name.Text) == 0)
                {
                	StringAssert.IsMatch("UK", obj_country.ToString());
                }
            }
        }
        
        [Test]
        public void ShouldFindElementByRepeaterColumn()
        {
            GetPageContent("ng_service_example.htm");
            ReadOnlyCollection<NgWebElement> ng_countries = ngDriver.FindElements(NgBy.RepeaterColumn("person in people", "person.Country"));
            
            Assert.AreEqual(3, ng_countries.Count(o => String.Compare("Mexico", o.Text,
                                                              StringComparison.InvariantCulture) == 0) );
        }
        
        [Test] 
        public void ShouldFindSelectedtOption(){
        	
        	GetPageContent("bind_select_option_data_from_array_example.htm");
        	NgWebElement ng_element = ngDriver.FindElement(NgBy.SelectedOption("myChoice"));
        	StringAssert.IsMatch("three", ng_element.Text);
        	Assert.IsTrue(ng_element.Displayed);
        }
        
        [Test] 
        public void ShouldChangeSelectedtOption(){
        	
        	GetPageContent("bind_select_option_data_from_array_example.htm");
        	
        	ReadOnlyCollection<NgWebElement> ng_elements = ngDriver.FindElements(NgBy.Repeater("option in options"));
        	NgWebElement ng_element = ng_elements.First(o => String.Compare("two", o.Text,
        	                                                        StringComparison.InvariantCulture) == 0);
        	ng_element.Click();
        	string text = ng_element.Text;
        	// Trigger WaitForAngular()
        	Assert.IsTrue(ng_element.Displayed); 
        	ng_element = ngDriver.FindElement(NgBy.SelectedOption("myChoice"));
        	StringAssert.IsMatch(text, ng_element.Text);
        	// Assert.IsTrue(ng_element.Displayed);
        }
        

        [Test]
        public void ShouldFindRows()
        {
            GetPageContent("ng_repeat_start_and_ng_repeat_end_example.htm");
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Repeater("definition in definitions"));
            Assert.IsTrue(elements[0].Displayed);
            StringAssert.AreEqualIgnoringCase(elements[0].Text, "Foo");
        }

        [Test]
        public void ShouldFindCells()
        {
            GetPageContent("ng_repeat_start_and_ng_repeat_end_example.htm");
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.RepeaterColumn("definition in definitions", "definition.text"));
            Assert.AreEqual(elements.Count, 2);
            StringAssert.IsMatch("Lorem ipsum", elements[0].Text);
        }

        [Test]
        public void ShouldFindTokens()
        {
            GetPageContent("ng_table1.html");
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.RepeaterColumn("x in names", "Country"));
            Assert.AreNotEqual(0, elements.Count);
            StringAssert.IsMatch("Germany", elements[0].Text);
            StringAssert.IsMatch("Mexico", elements[1].Text);
        }

        [Test]
        public void ShouldFindOptions()
        {
            // base_url = "http://www.java2s.com/Tutorials/AngularJSDemo/n/ng_options_with_object_example.htm";
            GetPageContent("ng_options_with_object_example.htm");
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Options("c.name for c in colors"));
            Assert.AreEqual(5, elements.Count);
            StringAssert.IsMatch("black", elements[0].Text);
            StringAssert.IsMatch("white", elements[1].Text);
        }

    }
}
