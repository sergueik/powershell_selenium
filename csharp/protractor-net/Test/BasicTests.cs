using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Edge;

namespace Protractor.Test
{
	[TestFixture]
	public class BasicTests
	{
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private String base_url = "http://www.angularjs.org";
		
		[SetUp]
		public void SetUp()
		{
			driver = new PhantomJSDriver();
			driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			
			// Using NuGet Package 'WebDriver.ChromeDriver.win32'
			//driver = new ChromeDriver();

			// Using Internet Explorer
			//var options = new InternetExplorerOptions() { IntroduceInstabilityByIgnoringProtectedModeSettings = true };
			//driver = new InternetExplorerDriver(options);

			// Using Microsoft Edge
			//driver = new EdgeDriver();

			// Required for TestForAngular and WaitForAngular scripts
			driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			ngDriver = new NgWebDriver(driver);
			ngDriver.Navigate().GoToUrl(base_url);
		}

		[TearDown]
		public void TearDown()
		{
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void ShouldWaitForAngular()
		{
			IWebElement element = ngDriver.FindElement(NgBy.Model("yourName"));
			Assert.IsTrue(((NgWebElement)element).Displayed);
		}

		[Test]
		public void ShouldSetLocation()
		{
			String loc = "misc/faq";
			NgNavigation nav = new NgNavigation(ngDriver, ngDriver.Navigate());
			nav.SetLocation(null, loc);
			Assert.IsTrue(ngDriver.Url.ToString().Contains(loc));
		}

		
		[Test]
		public void ShouldGreetUsingBinding()
		{
			ngDriver.FindElement(NgBy.Model("yourName")).SendKeys("Julie");
			Assert.AreEqual("Hello Julie!", ngDriver.FindElement(NgBy.Binding("yourName")).Text);
		}
		
		[Test]
		public void ShouldTestForAngular()
		{
			Assert.AreEqual(true, ngDriver.TestForAngular());
		}
		
		[Test]
		public void ShouldListTodos()
		{
			var elements = ngDriver.FindElements(NgBy.Repeater("todo in todoList.todos"));
			Assert.AreEqual("build an angular app", elements[1].Text);
			Assert.AreEqual(false, elements[1].Evaluate("todo.done"));
		}

		[Test]
		public void ShouldDetectNonAngularPage()
		{
			ngDriver.IgnoreSynchronization = true;
			Assert.DoesNotThrow(() => {
				ngDriver.Navigate().GoToUrl("http://www.google.com");
			});
			Assert.AreEqual(false, ngDriver.TestForAngular());
			ngDriver.IgnoreSynchronization = false;
		}
	}
}
