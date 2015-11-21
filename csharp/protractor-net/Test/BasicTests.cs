using System;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;

namespace Protractor.Samples.Basic
{
    [TestFixture]
    public class BasicTests
    {
        private IWebDriver driver;
        private String base_url = "http://www.angularjs.org";

        [SetUp]
        public void SetUp()
        {
            // Using NuGet Package 'PhantomJS'
            driver = new PhantomJSDriver();

            // Using NuGet Package 'WebDriver.ChromeDriver.win32'
            //driver = new ChromeDriver();

            // Using NuGet Package 'WebDriver.IEDriverServer.win32'
            //var options = new InternetExplorerOptions() { IntroduceInstabilityByIgnoringProtectedModeSettings = true };
            //driver = new InternetExplorerDriver(options);

            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
        }

        [TearDown]
        public void TearDown()
        {
            driver.Quit();
        }

        [Test]
        public void ShouldWaitForAngular()
        {
            IWebDriver ngDriver = new NgWebDriver(driver);
            ngDriver.Navigate().GoToUrl(base_url);
            IWebElement element = ngDriver.FindElement(NgBy.Model("yourName"));
            Assert.IsTrue(((NgWebElement)element).Displayed);
        }

        [Test]
        public void ShouldGreetUsingBinding()
        {
            IWebDriver ngDriver = new NgWebDriver(driver);
            ngDriver.Navigate().GoToUrl(base_url );
            ngDriver.FindElement(NgBy.Model("yourName")).SendKeys("Julie");
            Assert.AreEqual("Hello Julie!", ngDriver.FindElement(NgBy.Binding("yourName")).Text);
        }
        
        /*
        [Test]
        public void ShouldTestForAngular()
        {
            var ngDriver = new NgWebDriver(driver);
            object isAngularApp =  ngDriver.jsExecutor.ExecuteAsyncScript(ClientSideScripts.TestForAngular, 100);
            Assert.AreEqual(true, isAngularApp);
        }
        */
       
        [Test]
        public void ShouldListTodos()
        {
            var ngDriver = new NgWebDriver(driver);
            ngDriver.Navigate().GoToUrl("http://www.angularjs.org");
            var elements = ngDriver.FindElements(NgBy.Repeater("todo in todoList.todos"));
            Assert.AreEqual("build an angular app", elements[1].Text);
            Assert.AreEqual(false, elements[1].Evaluate("todo.done"));
        }
    }
}
