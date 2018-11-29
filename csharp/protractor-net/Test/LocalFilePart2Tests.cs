using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using System.Threading;

using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Support.UI;

using FluentAssertions;
using Protractor.Extensions;
using Protractor.TestUtils;

namespace Protractor.Test
{

	[TestFixture]
	public class LocalFilePart2Tests {
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private WebDriverWait wait;
		private Actions actions;
		private bool headless = true;
		private const int wait_seconds = 3;
		private const long wait_poll_milliseconds = 300;

		// private String testpage;
		private SimpleHTTPServer pageServer;
		private int port = 0;

		[TestFixtureSetUp]
		public void SetUp() {
			// check that the prcess can create web servers
			bool isProcessElevated =  ElevationChecker.IsProcessElevated(false);
			Assert.IsTrue(isProcessElevated, "This test needs to run from an elevated IDE or nunit console");
			Console.Error.WriteLine(String.Format("Verified elevation: {0}", isProcessElevated));
			// initialize custom HttpListener subclass to host the local files
			// https://docs.microsoft.com/en-us/dotnet/api/system.net.httplistener?redirectedfrom=MSDN&view=netframework-4.7.2
			String filePath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", "");
			
			// Console.Error.WriteLine(String.Format("Using Webroot path: {0}", filePath));
			pageServer = new SimpleHTTPServer(filePath);
			// implicitly does pageServer.Initialize() and  pageServer.Listen();
			port = pageServer.Port;
			// Console.Error.WriteLine(String.Format("Using Port {0}", port));

			// initialize the Selenium driver
			// driver = new FirefoxDriver();
			// System.InvalidOperationException : Access to 'file:///...' from script denied (UnexpectedJavaScriptError)
			if (headless) { 
				var option = new ChromeOptions();
				option.AddArgument("--headless");
				driver = new ChromeDriver(option);
			} else {
				driver = new ChromeDriver();
			}
			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(60);

			ngDriver = new NgWebDriver(driver);
			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			wait.PollingInterval = TimeSpan.FromMilliseconds(wait_poll_milliseconds);
			actions = new Actions(driver);
		}

		[TestFixtureTearDown]
		public void TearDown()
		{
			pageServer.Stop();
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.IsEmpty(verificationErrors.ToString());
		}

		[Test]
		public void ShouldFindAllBindings()
		{
			GetLocalHostPageContent("ng_directive_binding.htm");
			IWebElement container = ngDriver.FindElement(By.CssSelector("body div"));
			Console.Error.WriteLine(container.GetAttribute("innerHTML"));
			ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Binding("name"));
			Assert.AreEqual(5, elements.Count);
			foreach (NgWebElement element in elements) {
				Console.Error.WriteLine(element.GetAttribute("outerHTML"));
				Console.Error.WriteLine(String.Format("Identity: {0}", element.IdentityOf()));
				Console.Error.WriteLine(String.Format("Text: {0}", element.Text));
			}
		}

		[Test]
		public void ShouldFindCells()
		{
			//  NOTE: works with Angular 1.2.13, fails with Angular 1.4.9
			GetLocalHostPageContent("ng_repeat_start_end.htm");
			ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.RepeaterColumn("definition in definitions", "definition.text"));
			Assert.AreEqual(2, elements.Count);
			StringAssert.IsMatch("Lorem ipsum", elements[0].Text);
		}

		[Test]
		// [Ignore("Ignore test to prevent exception crashing later tests")]
		public void ShouldFindElementByModel()
		{
			//  NOTE: works with Angular 1.2.13, fails with Angular 1.4.9
			GetLocalHostPageContent("ng_pattern_validate.htm");
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
			GetLocalHostPageContent("ng_service.htm");
			// TODO: properly wait for Angular service to complete
			Thread.Sleep(3000);
			// wait.Until(ExpectedConditions.ElementIsVisible(NgBy.Repeater("person in people")));
			ReadOnlyCollection<NgWebElement> ng_people = ngDriver.FindElements(NgBy.Repeater("person in people"));
			if (ng_people.Count > 0) {
				ng_people = ngDriver.FindElements(NgBy.Repeater("person in people"));
				var check = ng_people.Select(o => o.FindElement(NgBy.Binding("person.Country")));
				Assert.AreEqual(ng_people.Count, check.Count());
				ReadOnlyCollection<NgWebElement> ng_countries = ngDriver.FindElements(NgBy.RepeaterColumn("person in people", "person.Country"));

				Assert.AreEqual(3, ng_countries.Count(o => String.Compare("Mexico", o.Text,
					StringComparison.InvariantCulture) == 0));
			}
		}

		[Test]
		public void ShouldFindOrderByField()
		{
			GetLocalHostPageContent("ng_headers_sort_example1.htm");

			String[] headers = new String[] { "First Name", "Last Name", "Age" };
			foreach (String header in headers) {
				IWebElement headerelement = ngDriver.FindElement(By.XPath(String.Format("//th/a[contains(text(),'{0}')]", header)));
				Console.Error.WriteLine(header);
				headerelement.Click();
				// to trigger WaitForAngular
				Assert.IsNotEmpty(ngDriver.Url);
				IWebElement emp = ngDriver.FindElement(NgBy.Repeater("emp in data.employees"));
				NgWebElement ngRow = new NgWebElement(ngDriver, emp);
				String orderByField = emp.GetAttribute("ng-order-by");
				Console.Error.WriteLine(orderByField + ": " + ngRow.Evaluate(orderByField).ToString());
			}
		}

		[Test]
		public void ShouldFindRepeaterSelectedtOption() {
			GetLocalHostPageContent("ng_repeat_selected.htm");
			NgWebElement ng_element = ngDriver.FindElement(NgBy.SelectedRepeaterOption("fruit in Fruits"));
			StringAssert.IsMatch("Mango", ng_element.Text);
		}

		[Test]
		public void ShouldFindRows()
		{
			GetLocalHostPageContent("ng_repeat_start_end.htm");
			ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Repeater("definition in definitions"));
			Assert.IsTrue(elements[0].Displayed);

			StringAssert.AreEqualIgnoringCase(elements[0].Text, "Foo");
		}


		[Test]
		public void ShouldHandleAngularUISelect()
		{
			GetLocalHostPageContent("ng_ui_select_example1.htm");
			ReadOnlyCollection<NgWebElement> ng_selected_colors = ngDriver.FindElements(NgBy.Repeater("$item in $select.selected"));
			Assert.IsTrue(2 == ng_selected_colors.Count);
			foreach (NgWebElement ng_selected_color in ng_selected_colors) {
				ngDriver.Highlight(ng_selected_color);
				Object selected_color_item = ng_selected_color.Evaluate("$item");
				Console.Error.WriteLine(String.Format("selected color: {0}", selected_color_item.ToString()));
			}
			// IWebElement search = ngDriver.FindElement(By.CssSelector("input[type='search']"));
			// same element
			NgWebElement ng_search = ngDriver.FindElement(NgBy.Model("$select.search"));
			ng_search.Click();
			int wait_seconds = 3;
			WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			// https://stackoverflow.com/questions/10934305/selenium-c-sharp-webdriver-how-to-detect-if-element-is-visible
			/*
			wait.Until(d => (d.FindElements(By.CssSelector("div[role='option']"))).Count > 0);
			*/
			/*
			wait.Until(d => {
				IWebElement element = null;
				try {
					
					element = d.FindElement(By.CssSelector("div[role='option']"));
					return element.Displayed && element.Enabled;
				} catch (NoSuchElementException exception) {
					return false;
				}
			});
			 */
			wait.Until(d => {
				IWebElement element = null;
				if (TryFindElement(By.CssSelector("div[role='option']"), out element)) {
					
					return element.Displayed && element.Enabled;
					
				} else {
					return false;
				}
			});

			ReadOnlyCollection<NgWebElement> ng_available_colors = ngDriver.FindElements(By.CssSelector("div[role='option']"));
			Assert.IsTrue(6 == ng_available_colors.Count);
			foreach (NgWebElement ng_available_color in ng_available_colors) {
				ngDriver.Highlight(ng_available_color);
				int available_color_index = -1;
				try {
					available_color_index = Int32.Parse(ng_available_color.Evaluate("$index").ToString());
				} catch (Exception) {
					// ignore
				}
				Console.Error.WriteLine(String.Format("available color [{1}]:{0}", ng_available_color.Text, available_color_index));
			}
		}

		[Test]
		public void ShouldHandleDeselectAngularUISelect()
		{
			GetLocalHostPageContent("ng_ui_select_example1.htm");
			ReadOnlyCollection<NgWebElement> ng_selected_colors = ngDriver.FindElements(NgBy.Repeater("$item in $select.selected"));
			while (true) {
				ng_selected_colors = ngDriver.FindElements(NgBy.Repeater("$item in $select.selected"));
				if (ng_selected_colors.Count == 0) {
					break;
				}
				NgWebElement ng_deselect_color = ng_selected_colors.Last();
				Object itemColor = ng_deselect_color.Evaluate("$item");
				Console.Error.WriteLine(String.Format("Deselecting color: {0}", itemColor.ToString()));
				IWebElement ng_close = ng_deselect_color.FindElement(By.CssSelector("span[class *='close']"));
				Assert.IsNotNull(ng_close);
				Assert.IsNotNull(ng_close.GetAttribute("ng-click"));
				StringAssert.IsMatch(@"removeChoice", ng_close.GetAttribute("ng-click"));

				ngDriver.Highlight(ng_close);
				ng_close.Click();
				// ngDriver.waitForAngular();

			}
			Console.Error.WriteLine("Nothing is selected");

		}

		[Test]
		public void ShouldFindSelectedtOption()
		{
			GetLocalHostPageContent("ng_select_array.htm");
			NgWebElement ng_element = ngDriver.FindElement(NgBy.SelectedOption("myChoice"));
			StringAssert.IsMatch("three", ng_element.Text);
			Assert.IsTrue(ng_element.Displayed);
		}

		public bool TryFindElement(By by, out IWebElement element)
		{
			try {
				element = driver.FindElement(by);
			} catch (NoSuchElementException) {
				element = null;
				return false;
			}
			return true;
		}
		
		[Test]
		public void ShouldHandleFluentExceptions()
		{
			GetLocalHostPageContent("ng_repeat_start_end.htm");
			Action a = () => {
				var displayed = ngDriver.FindElement(NgBy.Repeater("this is not going to be found")).Displayed;
			};
			// NoSuchElement Exception is not thrown by Protractor
			// a.ShouldThrow<NoSuchElementException>().WithMessage("Could not find element by: NgBy.Repeater:");
			a.ShouldThrow<NullReferenceException>();
		}

		[Test]
		public void ShouldHandleMultiSelect()
			// appears to be broken in PahtomJS / working in desktop browsers
		{
			Actions actions = new Actions(ngDriver.WrappedDriver);
			GetLocalHostPageContent("ng_multi_select.htm");
			IWebElement element = ngDriver.FindElement(NgBy.Model("selectedValues"));
			// use core Selenium
			IList<IWebElement> options = new SelectElement(element).Options;
			IEnumerator<IWebElement> etr = options.Where(o => Convert.ToBoolean(o.GetAttribute("selected"))).GetEnumerator();
			while (etr.MoveNext()) {
				Console.Error.WriteLine(etr.Current.Text);
			}
			foreach (IWebElement option in options) {
				// http://selenium.googlecode.com/svn/trunk/docs/api/dotnet/html/AllMembers_T_OpenQA_Selenium_Keys.htm
				actions.KeyDown(Keys.Control).Click(option).KeyUp(Keys.Control).Build().Perform();
				// triggers ngDriver.WaitForAngular()
				Assert.IsNotEmpty(ngDriver.Url);
			}
			// re-read select options
			element = ngDriver.FindElement(NgBy.Model("selectedValues"));
			options = new SelectElement(element).Options;
			etr = options.Where(o => Convert.ToBoolean(o.GetAttribute("selected"))).GetEnumerator();
			while (etr.MoveNext()) {
				Console.Error.WriteLine(etr.Current.Text);
			}
		}

		[Test]
		public void ShouldPrintOrderByFieldColumn()
		{
			GetLocalHostPageContent("ng_headers_sort_example2.htm");
			String[] headers = new String[] { "First Name", "Last Name", "Age" };
			foreach (String header in headers) {
				for (int cnt = 0; cnt != 2; cnt++) {
					IWebElement headerElement = ngDriver.FindElement(By.XPath("//th/a[contains(text(),'" + header + "')]"));
					Console.Error.WriteLine("Clicking on header: " + header);
					headerElement.Click();
					// triggers ngDriver.WaitForAngular()
					Assert.IsNotEmpty(ngDriver.Url);
					ReadOnlyCollection<NgWebElement> ng_emps = ngDriver.FindElements(NgBy.Repeater("emp in data.employees"));
					NgWebElement ng_emp = ng_emps[0];
					String field = ng_emp.GetAttribute("ng-order-by");
					Console.Error.WriteLine(field + ": " + ng_emp.Evaluate(field).ToString());
					String empField = "emp." + ng_emp.Evaluate(field);
					Console.Error.WriteLine(empField + ":");
					var ng_emp_enumerator = ng_emps.GetEnumerator();
					ng_emp_enumerator.Reset();
					while (ng_emp_enumerator.MoveNext()) {
						ng_emp = (NgWebElement)ng_emp_enumerator.Current;
						if (ng_emp.Text == null) {
							break;
						}
						Assert.IsNotNull(ng_emp.WrappedElement);

						try {
							NgWebElement ng_column = ng_emp.FindElement(NgBy.Binding(empField));
							Assert.IsNotNull(ng_column);
							Console.Error.WriteLine(ng_column.Text);
						} catch (Exception ex) {
							Console.Error.WriteLine(ex.ToString());
						}
					}
				}
			}
		}


		[Test]
		public void ShouldHandleSearchAngularUISelect()
		{
			GetLocalHostPageContent("ng_ui_select_example1.htm");
			String searchText = "Ma";
			IWebElement search = ngDriver.FindElement(By.CssSelector("input[type='search']"));
			search.SendKeys(searchText);
			NgWebElement ng_search = new NgWebElement(ngDriver, search);

			StringAssert.IsMatch(@"input", ng_search.TagName); // triggers  ngDriver.waitForAngular();
			ReadOnlyCollection<IWebElement> available_colors = ngDriver.WrappedDriver.FindElements(By.CssSelector("div[role='option']"));

			var matching_colors = available_colors.Where(color => color.Text.Contains(searchText));
			foreach (IWebElement matching_color in matching_colors) {
				ngDriver.Highlight(matching_color);
				Console.Error.WriteLine(String.Format("Matched color: {0}", matching_color.Text));
			}
		}

		[Test]
		[Ignore("Ignore test to debug the main expectation Expected: True But was: False to be solved")]
		public void ShouldNavigateDatesInDatePicker()
		{
			GetLocalHostPageContent("ng_datepicker.htm");
			NgWebElement ng_result = ngDriver.FindElement(NgBy.Model("data.inputOnTimeSet"));
			ng_result.Clear();
			ngDriver.Highlight(ng_result);
			IWebElement calendar = ngDriver.FindElement(By.CssSelector(".input-group-addon"));
			ngDriver.Highlight(calendar);
			Actions actions = new Actions(ngDriver.WrappedDriver);
			actions.MoveToElement(calendar).Click().Build().Perform();

			IWebElement dropdown = driver.FindElement(By.CssSelector("div.dropdown.open ul.dropdown-menu"));
			NgWebElement ng_dropdown = new NgWebElement(ngDriver, dropdown);
			Assert.IsNotNull(ng_dropdown);
			NgWebElement ng_display = ngDriver.FindElement(NgBy.Binding("data.previousViewDate.display"));
			Assert.IsNotNull(ng_display);
			String dateDattern = @"\d{4}\-(?<month>\w{3})";

			Regex dateDatternReg = new Regex(dateDattern);

			Assert.IsTrue(dateDatternReg.IsMatch(ng_display.Text));
			ngDriver.Highlight(ng_display);
			String display_month = ng_display.Text.FindMatch(dateDattern);
			// Console.Error.WriteLine("Current month: " + ng_display.Text);
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
			Console.Error.WriteLine("Next month: " + next_month);
			IWebElement ng_right = ng_display.FindElement(By.XPath("..")).FindElement(By.ClassName("right"));
			Assert.IsNotNull(ng_right);
			ngDriver.Highlight(ng_right, 100);
			ng_right.Click();
			Assert.IsTrue(ng_display.Text.Contains(next_month));
			ngDriver.Highlight(ng_display);
			Console.Error.WriteLine("Next month: " + ng_display.Text);
		}

		[Test]
		[Ignore("Test is timing out - needs a fix")]
		public void ShouldProperlyHandeMixedPages()
		{
			NgWebElement element;
			ngDriver.Navigate().GoToUrl("http://dalelotts.github.io/angular-bootstrap-datetimepicker/");
			Action a = () => {
				element = ngDriver.FindElements(NgBy.Model("data.dateDropDownInput")).First();
				Console.Error.WriteLine("Type: {0}", element.GetAttribute("type"));
			};
			a.ShouldThrow<InvalidOperationException>();
			// it is somewhat hard to build expectation on exact exception message
			// Can't find variable: angular
			// [ng:test] no injector found for element argument to getTestability

			// '[ng-app]', '[data-ng-app]'
			element = ngDriver.FindElements(NgBy.Model("data.dateDropDownInput", "[data-ng-app]")).First();
			Assert.IsNotNull(element);
			Console.Error.WriteLine("Type: {0}", element.GetAttribute("type"));

		}

		private void GetPageContent(string filename)
		{
			ngDriver.Navigate().GoToUrl(new System.Uri(Path.Combine(Directory.GetCurrentDirectory(), filename)).AbsoluteUri);
		}

		private void GetLocalHostPageContent(string filename)
		{
			ngDriver.Navigate().GoToUrl(String.Format("http://127.0.0.1:{0}/{1}", port, filename));
		}

		private string CreateTempFile(string content)
		{
			FileInfo testFile = new FileInfo("webdriver.tmp");
			if (testFile.Exists) {
				testFile.Delete();
			}
			StreamWriter testFileWriter = testFile.CreateText();
			testFileWriter.WriteLine(content);
			testFileWriter.Close();
			return testFile.FullName;
		}
	}
}
