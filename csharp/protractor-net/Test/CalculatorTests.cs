using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
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

// origin: https://github.com/anthonychu/Protractor-Net-Demo/tree/master/Protractor-Net-Demo

namespace Protractor.Test
{
	[TestFixture]
	public class CalculatorTests
	{
		private StringBuilder _verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private String base_url = "http://juliemr.github.io/protractor-demo/";
		private bool headless = true;

		[TestFixtureSetUp]
		public void SetUp()
		{
			driver = new ChromeDriver();
            driver.Manage().Timeouts().AsynchronousJavaScript =  TimeSpan.FromSeconds(5);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			// driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
			ngDriver = new NgWebDriver(driver);
			ngDriver.Navigate().GoToUrl(base_url);
		}

		[TestFixtureTearDown]
		public void TearDown()
		{
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", _verificationErrors.ToString());
		}


		[Test]
		public void ShouldAdd()
		{

			StringAssert.AreEqualIgnoringCase(ngDriver.Title, "Super Calculator");

			var ng_first_operand = ngDriver.FindElement(NgBy.Model("first"));
			ng_first_operand.SendKeys("1");

			#pragma warning disable 618
			NgWebElement ng_second_operand = ngDriver.FindElement(NgBy.Input("second"));
			#pragma warning restore 618
			ng_second_operand.SendKeys("2");

			NgWebElement ng_math_operator_element = ngDriver.FindElement(NgBy.Options("value for (key, value) in operators"));
			Assert.AreEqual(ng_math_operator_element.Text, "+");

			IWebElement math_operator_element = ngDriver.FindElement(NgBy.SelectedOption("operator"));
			Assert.AreEqual(math_operator_element.Text, "+");

			IWebElement go_button_element = ngDriver.FindElement(NgBy.PartialButtonText("Go"));
			Assert.IsTrue(go_button_element.Displayed);

			var ng_go_button_element = ngDriver.FindElement(By.Id("gobutton"));
			ng_go_button_element.Click();
			string ng_go_button_element_css_selector = ng_go_button_element.CssSelectorOf();
			string ng_go_button_element_xpath = ng_go_button_element.XPathOf();

			NgWebElement result_element = ngDriver.FindElement(NgBy.Binding("latest"));
			Assert.AreEqual("3", result_element.Text);
			ngDriver.Highlight(result_element, 1000);
		}

		[Test]
		public void ShouldSubstract()
		{
			#pragma warning disable 618
			var first = ngDriver.FindElement(NgBy.Input("first"));
			#pragma warning restore 618
			first.SendKeys("10");

			#pragma warning disable 618
			var second = ngDriver.FindElement(NgBy.Input("second"));
			#pragma warning restore 618
			second.SendKeys("2");

			ReadOnlyCollection<NgWebElement> ng_math_operators = ngDriver.FindElements(NgBy.Options("value for (key, value) in operators"));
			NgWebElement ng_substract_math_operator = ng_math_operators.First(op => op.Text.Equals("-", StringComparison.Ordinal));
			Assert.IsNotNull(ng_substract_math_operator);
			ng_substract_math_operator.Click();

			var goButton = ngDriver.FindElement(By.Id("gobutton"));
			goButton.Click();
			NgWebElement result_element = ngDriver.FindElement(NgBy.Binding("latest"));
			Assert.AreEqual("8", result_element.Text);
			ngDriver.Highlight(result_element, 1000);
		}

	}
}
