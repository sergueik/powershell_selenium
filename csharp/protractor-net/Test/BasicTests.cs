using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Edge;

namespace Protractor.Test {
	[TestFixture]
	public class BasicTests {
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private bool headless = true;
		private String base_url = "http://www.angularjs.org";
		
		[SetUp]
		public void SetUp() {
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			
			// Using NuGet Package 'WebDriver.ChromeDriver.win32'
			if (headless) { 
				var option = new ChromeOptions();
				option.AddArgument("--headless");
				driver = new ChromeDriver(option);
			} else {
				driver = new ChromeDriver();
			}

			// Using Internet Explorer
			//var options = new InternetExplorerOptions() { IntroduceInstabilityByIgnoringProtectedModeSettings = true };
			//driver = new InternetExplorerDriver(options);

			// Using Microsoft Edge
			//driver = new EdgeDriver();

			// Required for TestForAngular and WaitForAngular scripts
            driver.Manage().Timeouts().AsynchronousJavaScript =  TimeSpan.FromSeconds(5);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			ngDriver = new NgWebDriver(driver);
			ngDriver.Navigate().GoToUrl(base_url);
		}

		[TearDown]
		public void TearDown() {
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void ShouldWaitForAngular() {
			IWebElement element = ngDriver.FindElement(NgBy.Model("yourName"));
			Assert.IsTrue(((NgWebElement)element).Displayed);
		}

		[Test]
		public void ShouldSetLocation() {
			String loc = "misc/faq";
			NgNavigation nav = new NgNavigation(ngDriver, ngDriver.Navigate());
			nav.SetLocation(null, loc);
			Assert.IsTrue(ngDriver.Url.ToString().Contains(loc));
		}

		// NOTE: Test passes when run alone, but randomly fails when run as a group
		[Test]
		public void ShouldGreetUsingBinding() {
			ngDriver.FindElement(NgBy.Model("yourName")).SendKeys("Julie");
			Assert.AreEqual("Hello Julie!", ngDriver.FindElement(NgBy.Binding("yourName")).Text);
		}
		
		[Test]
		public void ShouldTestForAngular() {
			Assert.AreEqual(true, ngDriver.TestForAngular());
		}
		
		[Test]
		public void ShouldListTodos() {
			var elements = ngDriver.FindElements(NgBy.Repeater("todo in todoList.todos"));
			Assert.AreEqual("build an AngularJS app", elements[1].Text);
			Assert.AreEqual(false, elements[1].Evaluate("todo.done"));
		}

		[Test]
		public void ShouldDetectNonAngularPage() {
			ngDriver.IgnoreSynchronization = true;
			Assert.DoesNotThrow(() => {
				ngDriver.Navigate().GoToUrl("http://www.google.com");
			});
			Assert.AreEqual(false, ngDriver.TestForAngular());
			ngDriver.IgnoreSynchronization = false;
		}
	
		[Test]
		public void ShouldExerciseCustomWaitMethod() {
			WaitInDomElement(By.TagName("div"));
		}

		// NOTE: cannot use with NgBy: 
		// first, NgBy is a static class (can remove static attribute), 
		// and "The best overloaded method match for 
		// 'OpenQA.Selenium.ISearchContext.FindElement(OpenQA.Selenium.By)' has some invalid arguments (CS1502)" 
		public void WaitInDomElement(By by) {
    	    var wait = new WebDriverWait(driver, TimeSpan.FromMilliseconds(60)){
                PollingInterval = TimeSpan.FromMilliseconds(500),
        	};

	        wait.Until(d => {
	                try {
	                    d.FindElement(by);
	                    return true;
	                } catch (NoSuchElementException) {
	                    return false;
	                } catch (StaleElementReferenceException) {
	                    return false;
	                }
            });
        }
	}
}
