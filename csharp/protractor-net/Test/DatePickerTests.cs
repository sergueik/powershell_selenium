using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections;
using System.Threading;
using System.Linq;

using NUnit.Framework;

using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using System.Drawing;
// using System.Windows.Forms;

using Protractor.Extensions;

// Angular UI  DatePicker tests
namespace Protractor.Test
{
	
	[TestFixture]
	public class DatePickerTests
	{
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private WebDriverWait wait;
		private const int wait_seconds = 3;
		private const int window_width = 900;
		private const int window_heght = 800;
		private String base_url = "http://dalelotts.github.io/angular-bootstrap-datetimepicker/";
		private int highlight_timeout = 1000;
		private Actions actions;

		[TestFixtureSetUp]
		public void SetUp()
		{
			driver = new ChromeDriver();
			driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
			ngDriver = new NgWebDriver(driver);
			driver.Manage().Window.Size = new System.Drawing.Size(window_width, window_heght);
			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			ngDriver.Navigate().GoToUrl(base_url);
			actions = new Actions(driver);
		}

		// Embedded calendar
		[Test]
		public void ShouldDirectSelectEmbedded()
		{
			// Arrange
			try {
				wait.Until(e => e.FindElements(
					By.ClassName("col-sm-6")).Any(element => element.Text.Contains("Embedded calendar")));
			} catch (Exception e) {
				verificationErrors.Append(e.Message);
			}
			NgWebElement ng_result = ngDriver.FindElement(NgBy.Model("data.embeddedDate", "*[data-ng-app]"));
			Assert.IsNotNull(ng_result);
			// NOTE: cannot highlight calendar, only individual days
			actions.MoveToElement(ng_result).Build().Perform();
			ngDriver.Highlight(ng_result);
            
			NgWebElement[] elements = ng_result.FindElements(NgBy.Repeater("dateObject in week.dates")).ToArray();
			Assert.IsTrue(28 <= elements.Length);
			// Act
			// Highlight every day in the month 
			int start = 0, end = elements.Length;
			for (int cnt = 0; cnt != elements.Length; cnt++) {
				if (start == 0 && Convert.ToInt32(elements[cnt].Text) == 1) {
					start = cnt;
				}
				if (cnt > start && Convert.ToInt32(elements[cnt].Text) == 1) {
					end = cnt;
				}
			}
			for (int cnt = start; cnt != end; cnt++) {
				NgWebElement element = elements[cnt];
				ngDriver.Highlight(element, highlight_timeout, 3, (element.GetAttribute("class").Contains("current")) ? "blue" : "green");
			}
		}
        
		// Drop-down Datetime with input box
		[Test]
		public void ShouldDirectSelectDropDownInputBox()
		{
			// Arrange
			try {
				wait.Until(e => e.FindElements(
					By.ClassName("col-sm-6")).Any(element => element.Text.IndexOf("Drop-down Datetime with input box", StringComparison.InvariantCultureIgnoreCase) > -1));
			} catch (Exception e) {
				verificationErrors.Append(e.Message);
			}
			NgWebElement ng_result = ngDriver.FindElement(NgBy.Model("data.dateDropDownInput", "*[data-ng-app]"));
			Assert.IsNotNull(ng_result);
			// ng_result.Clear();
			ngDriver.Highlight(ng_result);
			IWebElement calendar = ngDriver.FindElement(By.CssSelector(".input-group-addon"));
			Assert.IsNotNull(calendar);
			ngDriver.Highlight(calendar);
			Actions actions = new Actions(ngDriver.WrappedDriver);
			actions.MoveToElement(calendar).Click().Build().Perform();

			IWebElement dropdown = driver.FindElement(By.CssSelector("div.dropdown.open ul.dropdown-menu"));
			NgWebElement ng_dropdown = new NgWebElement(ngDriver, dropdown);
			Assert.IsNotNull(ng_dropdown);
			ReadOnlyCollection<NgWebElement> elements = ng_dropdown.FindElements(NgBy.Repeater("dateObject in week.dates"));
			Assert.IsTrue(28 <= elements.Count);

			String monthDate = "12";
			IWebElement dateElement = ng_dropdown.FindElements(NgBy.CssContainingText("td.ng-binding", monthDate)).First();
			Console.Error.WriteLine("Mondh Date: " + dateElement.Text);
			dateElement.Click();
			NgWebElement ng_element = ng_dropdown.FindElement(NgBy.Model("data.dateDropDownInput", "[data-ng-app]"));
			Assert.IsNotNull(ng_element);
			ngDriver.Highlight(ng_element);
			ReadOnlyCollection<NgWebElement> ng_dataDates = ng_element.FindElements(NgBy.Repeater("dateObject in data.dates"));
			Assert.AreEqual(24, ng_dataDates.Count);

			String timeOfDay = "6:00 PM";
			NgWebElement ng_hour = ng_element.FindElements(NgBy.CssContainingText("span.hour", timeOfDay)).First();
			Assert.IsNotNull(ng_hour);
			ngDriver.Highlight(ng_hour);
			Console.Error.WriteLine("Hour of the day: " + ng_hour.Text);
			ng_hour.Click();
			String specificMinute = "6:35 PM";

			// no need to reload
			ng_element = ng_dropdown.FindElement(NgBy.Model("data.dateDropDownInput", "*[data-ng-app]"));
			Assert.IsNotNull(ng_element);
			ngDriver.Highlight(ng_element);
			NgWebElement ng_minute = ng_element.FindElements(NgBy.CssContainingText("span.minute", specificMinute)).First();
			Assert.IsNotNull(ng_minute);
			ngDriver.Highlight(ng_minute);
			Console.Error.WriteLine("Time of the day: " + ng_minute.Text);
			ng_minute.Click();
			ng_result = ngDriver.FindElement(NgBy.Model("data.dateDropDownInput", "[data-ng-app]"));
			ngDriver.Highlight(ng_result, 100);
			Console.Error.WriteLine("Selected Date/time: " + ng_result.GetAttribute("value"));

		}
		[Test]
		public void ShouldNavigateDropDownInputBox()
		{
			// Open datepicker directive
			NgWebElement ng_result = ngDriver.FindElement(NgBy.Model("data.dateDropDownInput", "*[data-ng-app]"));
			Assert.IsNotNull(ng_result);
			// ng_result.Clear();
			ngDriver.Highlight(ng_result);
			IWebElement calendar = ngDriver.FindElement(By.CssSelector(".input-group-addon"));
			ngDriver.Highlight(calendar);
			Actions actions = new Actions(ngDriver.WrappedDriver);
			actions.MoveToElement(calendar).Click().Build().Perform();

			IWebElement dropdown = driver.FindElement(By.CssSelector("div.dropdown.open ul.dropdown-menu"));
			NgWebElement ng_dropdown = new NgWebElement(ngDriver, dropdown);
			Assert.IsNotNull(ng_dropdown);
			NgWebElement ng_display = ngDriver.FindElement(NgBy.Binding("data.previousViewDate.display", true, "[data-ng-app]"));
			Assert.IsNotNull(ng_display);
			String dateDattern = @"\d{4}\-(?<month>\w{3})";

			Regex dateDatternReg = new Regex(dateDattern);

			Assert.IsTrue(dateDatternReg.IsMatch(ng_display.Text));
			ngDriver.Highlight(ng_display);
			String display_month = ng_display.Text.FindMatch(dateDattern);

			String[] months = {
				"Jan",
				"Feb",
				"Mar",
				"Apr",
				"May",
				"Jun",
				"Jul",
				"Aug",
				"Sep",
				"Oct",
				"Dec",
				"Jan"
			};

			String next_month = months[Array.IndexOf(months, display_month) + 1];

			Console.Error.WriteLine("Current month: " + display_month);
			Console.Error.WriteLine("Expect to find next month: " + next_month);
			IWebElement ng_right = ng_display.FindElement(By.XPath("..")).FindElement(By.ClassName("right"));
			Assert.IsNotNull(ng_right);
			ngDriver.Highlight(ng_right, 100);
			ng_right.Click();
			Assert.IsTrue(ng_display.Text.Contains(next_month));
			ngDriver.Highlight(ng_display);
			Console.Error.WriteLine("Next month: " + ng_display.Text);
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
	}
}