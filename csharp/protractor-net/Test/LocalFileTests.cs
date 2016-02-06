using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Support.UI;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Threading;
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
        public void ShouldDropDown()
        {

            GetPageContent("ng_dropdown.htm");
            string optionsCountry = "country for (country, states) in countries";
            ReadOnlyCollection<NgWebElement> ng_countries = ngDriver.FindElements(NgBy.Options(optionsCountry));

            Assert.IsTrue(4 == ng_countries.Count);
            Assert.IsTrue(ng_countries[0].Enabled);
            string optionsState = "state for (state,city) in states";
            NgWebElement ng_state = ngDriver.FindElement(NgBy.Options(optionsState));
            Assert.IsFalse(ng_state.Enabled);
            SelectElement countries = new SelectElement(ngDriver.FindElement(NgBy.Model("states")).WrappedElement);
            countries.SelectByText("Australia");
            Thread.Sleep(1000);
            Assert.IsTrue(ng_state.Enabled);
            NgWebElement ng_selected_country = ngDriver.FindElement(NgBy.SelectedOption(optionsCountry));
            // TODO:debug (works in Java client)
            // Assert.IsNotNull(ng_selected_country.WrappedElement);
            // ng_countries = ngDriver.FindElements(NgBy.Options(optionsCountry));
            NgWebElement ng_country = ng_countries.First(o => o.WrappedElement.Selected);
            StringAssert.IsMatch("Australia", ng_country.Text);
        }

        [Test]
        public void ShouldDropDownWatch()
        {
            GetPageContent("ng_dropdown_watch.htm");
            string optionsCountry = "country for country in countries";
            ReadOnlyCollection<NgWebElement> ng_countries = ngDriver.FindElements(NgBy.Options(optionsCountry));

            Assert.IsTrue(3 == ng_countries.Count);
            Assert.IsTrue(ng_countries[0].Enabled);
            string optionsState = "state for state in states";
            NgWebElement ng_state = ngDriver.FindElement(NgBy.Options(optionsState));
            Assert.IsFalse(ng_state.Enabled);
            SelectElement countries = new SelectElement(ngDriver.FindElement(NgBy.Model("country")).WrappedElement);
            countries.SelectByText("china");
            Thread.Sleep(1000);
            Assert.IsTrue(ng_state.Enabled);
            NgWebElement ng_selected_country = ngDriver.FindElement(NgBy.SelectedOption("country"));
            Assert.IsNotNull(ng_selected_country.WrappedElement);
            NgWebElement ng_country = ng_countries.First(o => o.WrappedElement.Selected);
            StringAssert.IsMatch("china", ng_country.Text);

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
        public void ShouldFindElementByModel()
        {
        	//  NOTE: works with Angular 1.2.13, fails withAngular 1.4.9
            GetPageContent("use_ng_pattern_to_validate_example.htm");
            NgWebElement ng_input = ngDriver.FindElement(NgBy.Model("myVal"));
            ng_input.Clear();
            NgWebElement ng_valid = ngDriver.FindElement(NgBy.Binding("form.value.$valid"));
            StringAssert.IsMatch("false", ng_valid.Text);

            NgWebElement ng_pattern = ngDriver.FindElement(NgBy.Binding("form.value.$error.pattern"));
            StringAssert.IsMatch("false", ng_pattern.Text);

            NgWebElement ng_required = ngDriver.FindElement(NgBy.Binding("!!form.value.$error.required"));
            StringAssert.IsMatch("true", ng_required.Text);

            ng_input.SendKeys("42");
            Assert.IsTrue(ng_input.Displayed);
            ng_valid = ngDriver.FindElement(NgBy.Binding("form.value.$valid"));
            StringAssert.IsMatch("true", ng_valid.Text);

            ng_pattern = ngDriver.FindElement(NgBy.Binding("form.value.$error.pattern"));
            StringAssert.IsMatch("false", ng_pattern.Text);

            ng_required = ngDriver.FindElement(NgBy.Binding("!!form.value.$error.required"));
            StringAssert.IsMatch("false", ng_required.Text);

        }

        [Test]
        public void ShouldFindElementByRepeaterColumn()
        {
            GetPageContent("ng_service_example.htm");
            ReadOnlyCollection<NgWebElement> ng_countries = ngDriver.FindElements(NgBy.RepeaterColumn("person in people", "person.Country"));

            Assert.AreEqual(3, ng_countries.Count(o => String.Compare("Mexico", o.Text,
                                                              StringComparison.InvariantCulture) == 0));
        }

        [Test]
        public void ShouldFindSelectedtOption()
        {

            GetPageContent("bind_select_option_data_from_array_example.htm");
            //  NOTE: works with Angular 1.2.13, fails withAngular 1.4.9
            NgWebElement ng_element = ngDriver.FindElement(NgBy.SelectedOption("myChoice"));
            StringAssert.IsMatch("three", ng_element.Text);
            Assert.IsTrue(ng_element.Displayed);
        }

        [Test]
        public void ShouldChangeSelectedtOption()
        {

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
        public void ShouldFindCells()
        {
        	//  NOTE: works with Angular 1.2.13, fails withAngular 1.4.9
            GetPageContent("ng_repeat_start_and_ng_repeat_end_example.htm");
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.RepeaterColumn("definition in definitions", "definition.text"));
            Assert.AreEqual(2, elements.Count );
            StringAssert.IsMatch("Lorem ipsum", elements[0].Text);
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

        [Test]
        public void ShouldFindRows()
        {
            GetPageContent("ng_repeat_start_and_ng_repeat_end_example.htm");
            ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Repeater("definition in definitions"));
            Assert.IsTrue(elements[0].Displayed);
            StringAssert.AreEqualIgnoringCase(elements[0].Text, "Foo");
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

    }
}
