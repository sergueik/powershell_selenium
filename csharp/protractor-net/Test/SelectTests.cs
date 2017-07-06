using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;

using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using System.Threading;

using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using Protractor.Extensions;

// Tests of AngularJS Button embedded in nested iframe
namespace Protractor.Test
{
	[TestFixture]
	public class SelectTests
	{
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private WebDriverWait wait;
		private Actions actions;
		private IAlert alert;
		private string alert_text;

		private const int wait_seconds = 3;
		private const long wait_poll_milliseconds = 300;
		private String base_url = "https://plnkr.co/edit/vxwV6zxEwZGVUVR5V6tg?p=preview";
		private IWebDriver frame;

		[TestFixtureSetUp]
		public void SetUp()
		{
			driver = new ChromeDriver();
			ngDriver = new NgWebDriver(driver);
			driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			wait.PollingInterval = TimeSpan.FromMilliseconds(wait_poll_milliseconds);
			actions = new Actions(driver);

		}

		[TestFixtureTearDown]
		public void TearDown()
		{
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.IsEmpty(verificationErrors.ToString());
		}
		
		[Test]
		public void Should_SelectSingle()
		{
			driver.Navigate().GoToUrl(base_url);
			IWebElement frameElement = driver.FindElement(By.CssSelector("iframe[name='plunkerPreviewTarget']"));
			Assert.IsNotNull(frameElement);
			var iframe = driver.SwitchTo().Frame(frameElement);
			string header_text = "Single select example";
			wait.Until(ExpectedConditions.ElementExists(By.XPath(
				String.Format("//form/div[contains(text(), '{0}')]", header_text))));

			IWebElement header = iframe.FindElement(By.XPath(
				                     String.Format("//form/div[contains(text(), '{0}')]", header_text)));
			Assert.IsNotNull(header);
			actions.MoveToElement(header).Build().Perform();
			driver.Highlight(header);
			IWebElement selectOne = iframe.FindElement(By.XPath("//ng-select"));
			Assert.IsNotNull(selectOne);
			actions.MoveToElement(selectOne).Build().Perform();
			driver.Highlight(selectOne);
			Console.Error.WriteLine("Element contents:\n{0}", selectOne.GetAttribute("innerHTML"));
			String button_text = "Select one";			
			IWebElement selectButtonElement = selectOne.FindElement(By.XPath(String.Format("//div[@class='placeholder'][contains(text(), '{0}')]", button_text)));
			Assert.IsNotNull(selectButtonElement);

			actions.MoveToElement(selectButtonElement).Build().Perform();
			driver.Highlight(selectButtonElement);
			selectButtonElement.Click();
			Thread.Sleep(1000);
			wait.Until(d => (d.FindElements(By.CssSelector("select-dropdown div.options ul li")).Count > 0));
			IWebElement dropdownElement = iframe.FindElement(By.CssSelector("select-dropdown div.options"));
			Assert.IsNotNull(dropdownElement);
			IWebElement[] optionElements = dropdownElement.FindElements(By.CssSelector("ul li")).ToArray();
			Assert.IsTrue(1 <= optionElements.Length);
			foreach (IWebElement optionElement in optionElements) {
				// Console.Error.WriteLine("Option name:\n{0}", optionElement.GetAttribute("outerHTML"));
				Console.Error.WriteLine("Option text:{0}", optionElement.Text);
				actions.MoveToElement(optionElement).Build().Perform();
				driver.Highlight(optionElement);
				if (optionElement.Text.Contains("7")) {
					optionElement.Click();
				}
				try {
					NgWebElement ng_option_element = new NgWebElement(ngDriver, optionElement);
					Assert.IsNotNull(ng_option_element.WrappedElement);
					Console.Error.WriteLine("Option angular object:{0}\n", ng_option_element.Evaluate("ng-reflect-ng-outlet-context"));
				} catch (InvalidOperationException e) { 
					// ignore: angular is not defined
					Console.Error.WriteLine("Ignore exception: " + e.Message);
				} catch (StaleElementReferenceException e) { 
					break;
				}
			}
			
			IWebElement selectOptions = iframe.FindElement(By.XPath("//ng-select[@formcontrolname='selectSingle']/following-sibling::div"));
			Assert.IsNotNull(selectOptions);
			actions.MoveToElement(selectOptions).Build().Perform();
			driver.Highlight(selectOptions);
			String idPattern = @"Selected option id: (?<result>\d{1,2})";
			Regex idReg = new Regex(idPattern);
			Assert.IsTrue(idReg.IsMatch(selectOptions.Text));
			// TODO: debug 
			idPattern = @"Selected option id: (?<id>\d+)";
			int result = 0;
			int.TryParse(selectOptions.Text.FindMatch(idPattern), out result);
			// Assert.AreEqual(7, result);
		}
		

		[Test]
		public void Should_SelectMultipe()
		{
			driver.Navigate().GoToUrl(base_url);
			IWebElement frameElement = driver.FindElement(By.CssSelector("iframe[name='plunkerPreviewTarget']"));
			Assert.IsNotNull(frameElement);
			var iframe = driver.SwitchTo().Frame(frameElement);
			string header_text = "Multilpe select example";
			wait.Until(ExpectedConditions.ElementExists(By.XPath(
				String.Format("//form/div[contains(text(), '{0}')]", header_text))));

			IWebElement header = iframe.FindElement(By.XPath(
				                     String.Format("//form/div[contains(text(), '{0}')]", header_text)));
			Assert.IsNotNull(header);
			actions.MoveToElement(header).Build().Perform();
			iframe.Highlight(header);
			IWebElement selectMultiple = iframe.FindElement(By.CssSelector("div.multiple"));
			Assert.IsNotNull(selectMultiple);
			actions.MoveToElement(selectMultiple).Build().Perform();
			driver.Highlight(selectMultiple);
			

			int[] selectNumbers = new int[] { 2, 4, 5, 6 }; 
			for (int cnt = 0; cnt != selectNumbers.Length; cnt++) {
				int selectNumber = selectNumbers[cnt];
				IWebElement selectPlacholderElement;
				if (cnt == 0) {
					String button_text = "Select multiple";			
					selectPlacholderElement = selectMultiple.FindElement(By.CssSelector(String.Format("input[placeholder *= '{0}']", button_text)));
				} else {
					selectPlacholderElement = selectMultiple.FindElement(By.CssSelector("input[placeholder]"));
				}
				Assert.IsNotNull(selectPlacholderElement);
				actions.MoveToElement(selectPlacholderElement).Build().Perform();
				driver.Highlight(selectPlacholderElement);
				selectPlacholderElement.Click();
				IWebElement dropdownElement = iframe.FindElement(By.CssSelector("select-dropdown div.options"));
				Assert.IsNotNull(dropdownElement);
				IWebElement[] optionElements = dropdownElement.FindElements(By.CssSelector("ul li")).ToArray();
				Assert.IsTrue(1 <= optionElements.Length);
			
				foreach (IWebElement optionElement in optionElements) {
					// Console.Error.WriteLine("Option text:\"{0}\"", optionElement.Text);
					actions.MoveToElement(optionElement).Build().Perform();
					driver.Highlight(optionElement);
					String selectOption = String.Format("{0}", selectNumber).Trim();
					if (optionElement.Text.Contains(selectOption)) {
						Console.Error.WriteLine("Selecting option:\"{0}\"", selectOption);
						optionElement.Click();
						break;
					}
				}			
				Thread.Sleep(1000);
			}

			IWebElement selectOptions = iframe.FindElement(By.XPath("//ng-select[@formcontrolname='selectMultiple']/following-sibling::div"));
			Assert.IsNotNull(selectOptions);
			actions.MoveToElement(selectOptions).Build().Perform();
			driver.Highlight(selectOptions);
			String idPattern = @"Selected option id: (?<result>(?:\d{1,2}|,)+)";
			Regex idReg = new Regex(idPattern);
			Assert.IsTrue(idReg.IsMatch(selectOptions.Text));
			// TODO: debug 
			idPattern = @"Selected option id:(?<id>.+)$";
			//
			Console.Error.WriteLine("\"{0}\" processed as :\"{0}\"", selectOptions.Text, selectOptions.Text.FindMatch(idPattern));
		}
	}
}