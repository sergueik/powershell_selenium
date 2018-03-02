using System;
using System.Text;
using System.Text.RegularExpressions;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using System.Collections.ObjectModel;
using System.Collections;
using System.Threading;
using System.Linq;
using Protractor.Extensions;
//using System.Drawing;
//using System.Windows.Forms;

// tests of Native AngularJS multiselect directive https://github.com/amitava82/angular-multiselect

namespace Protractor.Test
{
	// NOTE: these tests are unstable in Chrome.
	// Tests pass when run alone, but randomly fail as a group
	[TestFixture]
	public class MultiSelectTests
	{
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private WebDriverWait wait;
		private const int wait_seconds = 3;
		private int highlight_timeout = 1000;
		private String base_url = "http://amitava82.github.io/angular-multiselect/";

		[TestFixtureSetUp]
		public void SetUp()
		{
			driver = new FirefoxDriver();
            driver.Manage().Timeouts().AsynchronousJavaScript =  TimeSpan.FromSeconds(5);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			// driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
			ngDriver = new NgWebDriver(driver);
			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			ngDriver.Navigate().GoToUrl(base_url);
		}

		[TestFixtureTearDown]
		public void TearDown()
		{
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void ShouldSelectOneByOne()
		{
			// Given multuselect directive
			NgWebElement ng_directive = ngDriver.FindElement(NgBy.Model("selectedCar"));
			Assert.IsNotNull(ng_directive.WrappedElement);
			Assert.That(ng_directive.TagName, Is.EqualTo("am-multiselect"));

			// open am-multiselect
			IWebElement toggleSelect = ng_directive.FindElement(By.CssSelector("button[ng-click='toggleSelect()']"));
			Assert.IsNotNull(toggleSelect);
			Assert.IsTrue(toggleSelect.Displayed);
			toggleSelect.Click();

			// When I want to select every "Audi", "Honda" or "Toyota" car
			String makeMatcher = "(?i:" + String.Join("|", new String[] {
				"audi",
				"honda",
				"toyota"
			}) + ")";
			ReadOnlyCollection<NgWebElement> cars = ng_directive.FindElements(NgBy.Repeater("i in items"));
			Assert.Greater(cars.Count(car => Regex.IsMatch(car.Text, makeMatcher)), 0);
			// And I pick every matching car one item at a time
			int selected_cars_count = 0;
			for (int num_row = 0; num_row < cars.Count(); num_row++) {
				NgWebElement ng_item = ng_directive.FindElement(NgBy.Repeaterelement("i in items", num_row, "i.label"));

				if (Regex.IsMatch(ng_item.Text, makeMatcher, RegexOptions.IgnoreCase)) {
					Console.Error.WriteLine("Selecting: " + ng_item.Text);
					ng_item.Click();
					selected_cars_count++;
					ngDriver.Highlight(ng_item, highlight_timeout);
				}
			}
			// Then button text shows the total number of cars I have selected
			IWebElement button = driver.FindElement(By.CssSelector("am-multiselect > div > button"));
			ngDriver.Highlight(button, highlight_timeout);
			StringAssert.IsMatch(@"There are (\d+) car\(s\) selected", button.Text);
			int displayed_count = 0;
			int.TryParse(button.Text.FindMatch(@"(?<count>\d+)"), out displayed_count);

			Assert.AreEqual(displayed_count, selected_cars_count);
			Console.Error.WriteLine("Button text: " + button.Text);

			try {
				// NOTE: the following does not work:
				// ms-selected = "There are {{selectedCar.length}}
				NgWebElement ng_button = new NgWebElement(ngDriver, button);
				Console.Error.WriteLine(ng_button.GetAttribute("innerHTML"));
				NgWebElement ng_length = ng_button.FindElement(NgBy.Binding("selectedCar.length"));
				ng_length = ngDriver.FindElement(NgBy.Binding("selectedCar.length"));
				Console.Error.WriteLine(ng_length.Text);
			} catch (NullReferenceException) {
			}
		}

		[Test]
		public void ShouldSelectAll()
		{
			// Given multuselect directive
			NgWebElement ng_directive = ngDriver.FindElement(NgBy.Model("selectedCar"));
			Assert.IsNotNull(ng_directive.WrappedElement);
			Assert.That(ng_directive.TagName, Is.EqualTo("am-multiselect"));

			// open am-multiselect
			IWebElement toggleSelect = ng_directive.FindElement(NgBy.ButtonText("Select Some Cars"));
			Assert.IsNotNull(toggleSelect);
			Assert.IsTrue(toggleSelect.Displayed);
			toggleSelect.Click();

			// When using 'check all' link
			wait.Until(o => (o.FindElements(By.CssSelector("button[ng-click='checkAll()']")).Count != 0));
			IWebElement check_all = ng_directive.FindElement(By.CssSelector("button[ng-click='checkAll()']"));
			Assert.IsTrue(check_all.Displayed);
			ngDriver.Highlight(check_all, highlight_timeout, 5, "blue");
			check_all.Click();

			// Then every car is selected

			// validatate the count
			ReadOnlyCollection<NgWebElement> cars = ng_directive.FindElements(NgBy.Repeater("i in items"));
			Assert.AreEqual(cars.Count(), cars.Count(car => (Boolean)car.Evaluate("i.checked")));

			// walk over
			foreach (NgWebElement ng_item in ng_directive.FindElements(NgBy.RepeaterColumn("i in items", "i.label"))) {
				if (Boolean.Parse(ng_item.Evaluate("i.checked").ToString())) {
					IWebElement icon = ng_item.FindElement(By.ClassName("glyphicon"));
					// NOTE: the icon attributes
					// <i class="glyphicon glyphicon-ok" ng-class="{'glyphicon-ok': i.checked, 'empty': !i.checked}"></i>
					StringAssert.Contains("{'glyphicon-ok': i.checked, 'empty': !i.checked}", icon.GetAttribute("ng-class"));
					Console.Error.WriteLine("Icon: " + icon.GetAttribute("class"));
					ngDriver.Highlight(ng_item, highlight_timeout);
				}
			}
			Thread.Sleep(1000);
		}

		// TODO: filter
		// <input class="form-control placeholder="Filter" ng-model="searchText.label">

	}
}
