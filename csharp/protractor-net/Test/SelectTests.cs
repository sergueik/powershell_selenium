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
		private const int wait_seconds = 10;
		private const long wait_poll_milliseconds = 500;
		private const string base_url = "https://plnkr.co/edit/vxwV6zxEwZGVUVR5V6tg";
		private IWebDriver iframe;

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

		[SetUp]
		public void TestSetUp()
		{
			driver.Navigate().GoToUrl(base_url);
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
		public void Should_Play()
		{
			wait.Until(ExpectedConditions.ElementExists(By.CssSelector(
				"body > nav button i.icon-play")));
			IWebElement buttonElement = driver.FindElement(By.CssSelector("body > nav button i.icon-play"));
			Assert.IsNotNull(buttonElement);
			driver.Highlight(buttonElement);
			buttonElement.Click();
			// 
			IWebElement frameElement = driver.FindElement(By.CssSelector("iframe[name='plunkerPreviewTarget']"));
			Assert.IsNotNull(frameElement);
		}
		
		[Test]
		public void Should_SelectSingle()
		{
			wait.Until(ExpectedConditions.ElementExists(By.CssSelector(
				"body > nav button i.icon-play")));
			IWebElement buttonElement = driver.FindElement(By.CssSelector("body > nav button i.icon-play"));
			Assert.IsNotNull(buttonElement);
			driver.Highlight(buttonElement);
			buttonElement.Click();
			// 
			// 
			IWebElement frameElement = driver.FindElement(By.CssSelector("iframe[name='plunkerPreviewTarget']"));
			Assert.IsNotNull(frameElement);
			iframe = driver.SwitchTo().Frame(frameElement);
			String headerText = "Single select example";
			Thread.Sleep(1500);
			wait.Until(ExpectedConditions.ElementExists(By.XPath(
				String.Format("//form/div[contains(text(), '{0}')]", headerText))));

			IWebElement header = iframe.FindElement(By.XPath(
				                     String.Format("//form/div[contains(text(), '{0}')]", headerText)));
			Assert.IsNotNull(header);
			actions.MoveToElement(header).Build().Perform();
			driver.Highlight(header);
			IWebElement selectOne = iframe.FindElement(By.XPath("//ng-select"));
			Assert.IsNotNull(selectOne);
			actions.MoveToElement(selectOne).Build().Perform();
			driver.Highlight(selectOne);
			Console.Error.WriteLine("Element contents:\n{0}", selectOne.GetAttribute("innerHTML"));
			String buttonText = "Select one";			
			IWebElement selectButtonElement = selectOne.FindElement(By.XPath(String.Format("//div[@class='placeholder'][contains(text(), '{0}')]", buttonText)));
			Assert.IsNotNull(selectButtonElement);

			actions.MoveToElement(selectButtonElement).Build().Perform();
			driver.Highlight(selectButtonElement);
			selectButtonElement.Click();
			wait.Until(d => (d.FindElements(By.CssSelector("select-dropdown div.options ul li")).Count > 0));
			IWebElement dropdownElement = iframe.FindElement(By.CssSelector("select-dropdown div.options"));
			Assert.IsNotNull(dropdownElement);
			IWebElement[] optionElements = dropdownElement.FindElements(By.CssSelector("ul li")).ToArray();
			Assert.IsTrue(1 <= optionElements.Length);
			foreach (IWebElement optionElement in optionElements) {
				actions.MoveToElement(optionElement).Build().Perform();
				if (optionElement.Text.Contains("10")) {
					Console.Error.WriteLine("Selecting option:\"{0}\"", optionElement.Text);
					driver.Highlight(optionElement);
					optionElement.Click();
				}
				try {
					NgWebElement ng_option_element = new NgWebElement(ngDriver, optionElement);
					Assert.IsNotNull(ng_option_element.WrappedElement);
					Console.Error.WriteLine("Option angular object:{0}\n", ng_option_element.Evaluate("ng-reflect-ng-outlet-context"));
				} catch (InvalidOperationException e) { 
					// angular is not defined
					Console.Error.WriteLine("Ignore exception: " + e.Message);
				} catch (StaleElementReferenceException) { 
					break;
				}
			}
			
			IWebElement selectOptions = iframe.FindElement(By.XPath("//ng-select[@formcontrolname='selectSingle']/following-sibling::div"));
			Assert.IsNotNull(selectOptions);
			actions.MoveToElement(selectOptions).Build().Perform();
			driver.Highlight(selectOptions);			

			String idPattern = @"Selected option id: (?<result>\d{1,2})";
			
			Assert.IsTrue((new Regex(idPattern)).IsMatch(selectOptions.Text));
			int result = 0;
			int.TryParse(selectOptions.Text.FindMatch(idPattern), out result);
			Assert.AreEqual(10, result);
			Console.Error.WriteLine("FindMatch result: {0}\n", result.ToString());
		}
		
		[Test]
		public void Should_SelectMultipe()
		{
			wait.Until(ExpectedConditions.ElementExists(By.CssSelector(
				"body > nav button i.icon-play")));
			IWebElement buttonElement = driver.FindElement(By.CssSelector("body > nav button i.icon-play"));
			Assert.IsNotNull(buttonElement);
			driver.Highlight(buttonElement);
			buttonElement.Click();
			IWebElement frameElement = driver.FindElement(By.CssSelector("iframe[name='plunkerPreviewTarget']"));
			Assert.IsNotNull(frameElement);
			iframe = driver.SwitchTo().Frame(frameElement);
			string headerText = "Multilpe select example";
			Thread.Sleep(1500);
			wait.Until(ExpectedConditions.ElementExists(By.XPath(
				String.Format("//form/div[contains(text(), '{0}')]", headerText))));

			IWebElement header = iframe.FindElement(By.XPath(
				                     String.Format("//form/div[contains(text(), '{0}')]", headerText)));
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
					String buttonText = "Select multiple";			
					selectPlacholderElement = selectMultiple.FindElement(By.CssSelector(String.Format("input[placeholder *= '{0}']", buttonText)));
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
					actions.MoveToElement(optionElement).Build().Perform();
					String selectOption = String.Format("{0}", selectNumber).Trim();
					if (optionElement.Text.Contains(selectOption)) {
						Console.Error.WriteLine("Selecting option:\"{0}\"", selectOption);
						driver.Highlight(optionElement);
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
			Assert.IsTrue((new Regex(idPattern)).IsMatch(selectOptions.Text));
			String result = selectOptions.Text.FindMatch(idPattern);
			Console.Error.WriteLine("\"{0}\" processed as :\"{1}\"", selectOptions.Text, result);
		}
	}
}