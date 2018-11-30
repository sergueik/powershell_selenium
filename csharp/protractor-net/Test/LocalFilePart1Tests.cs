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

namespace Protractor.Test {

	[TestFixture]
	public class LocalFilePart1Tests {
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

			// check that the process can create web servers
			bool isProcessElevated =  ElevationChecker.IsProcessElevated(false);
			Assert.IsTrue(isProcessElevated, "This test needs to run from an elevated IDE or nunit console");

			// initialize custom HttpListener subclass to host the local files
			// https://docs.microsoft.com/en-us/dotnet/api/system.net.httplistener?redirectedfrom=MSDN&view=netframework-4.7.2
			String filePath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", "");
			
			// Console.Error.WriteLine(String.Format("Using Webroot path: {0}", filePath));
			pageServer = new SimpleHTTPServer(filePath);
			// implicitly does pageServer.Initialize() and  pageServer.Listen();
			Common.Port = pageServer.Port;
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

			Common.NgDriver= ngDriver = new NgWebDriver(driver);
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
		public void ShouldDropDown() {
			Common.GetLocalHostPageContent("ng_dropdown.htm");
			string optionsCountry = "country for (country, states) in countries";
			ReadOnlyCollection<NgWebElement> ng_countries = ngDriver.FindElements(NgBy.Options(optionsCountry));

			Assert.IsTrue(4 == ng_countries.Count);
			Assert.IsTrue(ng_countries[0].Enabled);
			string optionsState = "state for (state,city) in states";
			NgWebElement ng_state = ngDriver.FindElement(NgBy.Options(optionsState));
			SelectElement countries = new SelectElement(ngDriver.FindElement(NgBy.Model("states")).WrappedElement);
			countries.SelectByText("Australia");
			Thread.Sleep(1000);
			Assert.IsTrue(ng_state.Enabled);
			NgWebElement ng_selected_country = ngDriver.FindElement(NgBy.SelectedOption(optionsCountry));
			// TODO:debug (works in Java client)
			// Assert.IsNotNull(ng_selected_country.WrappedElement);
			// ng_countries = ngDriver.FindElements(NgBy.Options(optionsCountry));
			NgWebElement ng_country = ng_countries.First(o => o.Selected);
			StringAssert.IsMatch("Australia", ng_country.Text);
		}

		[Test]
		public void ShouldDropDownWatch() {
			Common.GetLocalHostPageContent("ng_dropdown_watch.htm");
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
			NgWebElement ng_country = ng_countries.First(o => o.Selected);
			StringAssert.IsMatch("china", ng_country.Text);

		}

		[Test]
		public void ShouldEvaluateIf() {
			Common.GetLocalHostPageContent("ng_watch_ng_if.htm");
			IWebElement button = ngDriver.FindElement(By.CssSelector("button.btn"));
			NgWebElement ng_button = new NgWebElement(ngDriver, button);
			Object state = ng_button.Evaluate("!house.frontDoor.isOpen");
			Assert.IsTrue(Convert.ToBoolean(state));
			StringAssert.IsMatch("house.frontDoor.open()", button.GetAttribute("ng-click"));
			StringAssert.IsMatch("Open Door", button.Text);
			button.Click();
		}

		[Test]
		public void ShouldChangeRepeaterSelectedtOption() {
			Common.GetLocalHostPageContent("ng_repeat_selected.htm");
			NgWebElement ng_element = ngDriver.FindElement(NgBy.SelectedRepeaterOption("fruit in Fruits"));
			StringAssert.IsMatch("Mango", ng_element.Text);
			ReadOnlyCollection<NgWebElement> ng_elements = ngDriver.FindElements(NgBy.Repeater("fruit in Fruits"));
			ng_element = ng_elements.First(o => String.Compare("Orange", o.Text,
				StringComparison.InvariantCulture) == 0);
			ng_element.Click();
			string text = ng_element.Text;
			// to trigger WaitForAngular
			Assert.IsTrue(ng_element.Displayed);
			// reload
			ng_element = ngDriver.FindElement(NgBy.SelectedRepeaterOption("fruit in Fruits"));
			StringAssert.IsMatch("Orange", ng_element.Text);
		}

		[Test]
		public void ShouldChangeSelectedtOption() {
			Common.GetLocalHostPageContent("ng_select_array.htm");
			ReadOnlyCollection<NgWebElement> ng_elements = ngDriver.FindElements(NgBy.Repeater("option in options"));
			NgWebElement ng_element = ng_elements.First(o => String.Compare("two", o.Text,
				                          StringComparison.InvariantCulture) == 0);
			ng_element.Click();
			string text = ng_element.Text;
			// to trigger WaitForAngular
			Assert.IsTrue(ng_element.Displayed);

			ng_element = ngDriver.FindElement(NgBy.SelectedOption("myChoice"));
			StringAssert.IsMatch(text, ng_element.Text);
			Assert.IsTrue(ng_element.Displayed);
		}

		[Test]
		public void ShouldDirectSelectFromDatePicker() {
			Common.GetLocalHostPageContent("ng_datepicker.htm");
			// http://dalelotts.github.io/angular-bootstrap-datetimepicker/
			NgWebElement ng_result = ngDriver.FindElement(NgBy.Model("data.inputOnTimeSet"));
			ng_result.Clear();
			ngDriver.Highlight(ng_result);
			IWebElement calendar = ngDriver.FindElement(By.CssSelector(".input-group-addon"));
			ngDriver.Highlight(calendar);
			Actions actions = new Actions(ngDriver.WrappedDriver);
			actions.MoveToElement(calendar).Click().Build().Perform();

			int datepicker_width = 900;
			int datepicker_heght = 800;
			driver.Manage().Window.Size = new System.Drawing.Size(datepicker_width, datepicker_heght);
			IWebElement dropdown = driver.FindElement(By.CssSelector("div.dropdown.open ul.dropdown-menu"));
			NgWebElement ng_dropdown = new NgWebElement(ngDriver, dropdown);
			Assert.IsNotNull(ng_dropdown);
			ReadOnlyCollection<NgWebElement> elements = ng_dropdown.FindElements(NgBy.Repeater("dateObject in week.dates"));
			Assert.IsTrue(28 <= elements.Count);

			String monthDate = "12";
			IWebElement dateElement = ng_dropdown.FindElements(NgBy.CssContainingText("td.ng-binding", monthDate)).First();
			Console.Error.WriteLine("Mondh Date: " + dateElement.Text);
			dateElement.Click();
			NgWebElement ng_element = ng_dropdown.FindElement(NgBy.Model("data.inputOnTimeSet"));
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

			// reload
			// dropdown = driver.FindElement(By.CssSelector("div.dropdown.open ul.dropdown-menu"));
			// ng_dropdown = new NgWebElement(ngDriver, dropdown);
			ng_element = ng_dropdown.FindElement(NgBy.Model("data.inputOnTimeSet"));
			Assert.IsNotNull(ng_element);
			ngDriver.Highlight(ng_element);
			NgWebElement ng_minute = ng_element.FindElements(NgBy.CssContainingText("span.minute", specificMinute)).First();
			Assert.IsNotNull(ng_minute);
			ngDriver.Highlight(ng_minute);
			Console.Error.WriteLine("Time of the day: " + ng_minute.Text);
			ng_minute.Click();
			ng_result = ngDriver.FindElement(NgBy.Model("data.inputOnTimeSet"));
			ngDriver.Highlight(ng_result, 100);
			Console.Error.WriteLine("Selected Date/time: " + ng_result.GetAttribute("value"));
		}

		[Test]
		// note can't escape with ""
		// [Ignore("Ignore unfinished lovely \"maximum call stack size exceeded\" prevent exception crashing test")]
		public void ShouldFindOptions()
		{
			// base_url = "http://www.java2s.com/Tutorials/AngularJSDemo/n/ng_options_with_object_example.htm";
			Common.GetLocalHostPageContent("ng_options_with_object.htm");
			ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Options("c.name for c in colors"));
			Assert.AreEqual(5, elements.Count);
			try {
				List<Dictionary<String, String>> result = elements[0].ScopeOf();
			} catch (WebDriverException) {
				// Maximum call stack size exceeded.
				// TODO
			} catch (InvalidOperationException) {
				// Maximum call stack size exceeded.
				// TODO
			}
			StringAssert.IsMatch("black", elements[0].Text);
			StringAssert.IsMatch("white", elements[1].Text);
		}

		[Test]
		public void ShouldUpload()
		{
			Common.GetLocalHostPageContent("ng_upload1.htm");
			// NOTE: does not work with Common.GetPageContent("ng_upload1.htm");

			IWebElement file = driver.FindElement(By.CssSelector("div[ng-controller = 'myCtrl'] > input[type='file']"));
			Assert.IsNotNull(file);
			StringAssert.AreEqualIgnoringCase(file.GetAttribute("file-model"), "myFile");
			String localPath = Common.CreateTempFile("lorem ipsum dolor sit amet");


			IAllowsFileDetection fileDetectionDriver = driver as IAllowsFileDetection;
			if (fileDetectionDriver == null) {
				Assert.Fail("driver does not support file detection. This should not be");
			}

			fileDetectionDriver.FileDetector = new LocalFileDetector();

			try {
				file.SendKeys(localPath);
			} catch (WebDriverException e) {
				// the operation has timed out
				Console.Error.WriteLine(e.Message);
			}
			NgWebElement button = ngDriver.FindElement(NgBy.ButtonText("Upload"));
			button.Click();
			NgWebElement ng_file = new NgWebElement(ngDriver, file);
			Object myFile = ng_file.Evaluate("myFile");
			if (myFile != null) {
				Dictionary<String, Object> result = (Dictionary<String, Object>)myFile;
				Assert.IsTrue(result.Keys.Contains("name"));
				Assert.IsTrue(result.Keys.Contains("type"));
				Assert.IsTrue(result.Keys.Contains("size"));
			} else {
				Console.Error.WriteLine("myFile is null");
			}
			String script = "var e = angular.element(arguments[0]); var f = e.scope().myFile; if (f){return f.name} else {return null;}";
			try {
				Object result = ((IJavaScriptExecutor)driver).ExecuteScript(script, ng_file);
				if (result != null) {
					Console.Error.WriteLine(result.ToString());
				} else {
					Console.Error.WriteLine("result is null");
				}
			} catch (InvalidOperationException e) {
				Console.Error.WriteLine(e.Message);
			}
		}

		[Test]
		public void ShouldAngularTodoApp()
		{
			Common.GetLocalHostPageContent("ng_todo.htm");
			ReadOnlyCollection<NgWebElement> ng_todo_elements = ngDriver.FindElements(NgBy.Repeater("todo in todoList.todos"));
			String ng_identity = ng_todo_elements[0].IdentityOf();
			// <input type="checkbox" ng-model="todo.done" class="ng-pristine ng-untouched ng-valid">
			// <span class="done-true">learn angular</span>
			List<Dictionary<String, String>> todo_scope_data = ng_todo_elements[0].ScopeDataOf("todoList.todos");
			int todo_index = todo_scope_data.FindIndex(o => String.Equals(o["text"], "build an angular app"));
			Assert.AreEqual(1, todo_index);
			//foreach (var row in todo_scope_data)
			//{
			//    foreach (string key in row.Keys)
			//    {
			//        Console.Error.WriteLine(key + " " + row[key]);
			//    }
			//}
		}

		[Test]
		public void ShouldDragAndDrop()
		{
			Common.GetLocalHostPageContent("ng_drag_and_drop1.htm");
			ReadOnlyCollection<NgWebElement> ng_cars = ngDriver.FindElements(NgBy.Repeater("car in models.cars"));
			Assert.AreEqual(5, ng_cars.Count);
			foreach (NgWebElement ng_car in ng_cars) {
				try {
					ngDriver.Highlight(ng_car);
					actions.MoveToElement(ng_car).Build().Perform();
					IWebElement basket = driver.FindElement(By.XPath("//*[@id='my-basket']"));
					// works in Java, desktop browser
					actions.ClickAndHold(ng_car).MoveToElement(basket).Release().Build()
						.Perform();
					Thread.Sleep(1000);
					NgWebElement ng_basket = new NgWebElement(ngDriver, basket);
					ReadOnlyCollection<NgWebElement> ng_cars_basket = ng_basket.FindElements(NgBy.Repeater("car in models.basket"));
					NgWebElement ng_car_basket = ng_cars_basket.Last();

					Assert.IsTrue(ng_car_basket.Displayed);
					// {{ car.name }} - {{ car.modelYear }} ( {{ car.price | currency }} )
					Console.Error.WriteLine("%s - %s ( %s )", ng_car_basket.Evaluate("car.name"), ng_car_basket.Evaluate("car.modelYear"), ng_car_basket.Evaluate("car.price | currency"));
				} catch (Exception e) {
					// System.InvalidOperationException: Sequence contains no elements
					// TODO
					Console.Error.WriteLine(e.ToString());
				}
			}
		}
		
	}
}
