using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
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

// origin: https://github.com/qualityshepherd/protractor_example

namespace Protractor.Test
{
    [TestFixture]
    public class QualityShepherdTests
    {
        private StringBuilder verificationErrors = new StringBuilder();
        private IWebDriver driver;
        private int timeout = 1000;
        private NgWebDriver ngDriver;
        private String base_url = "http://qualityshepherd.com/angular/friends/";

        [TestFixtureSetUp]
        public void SetUp()
        {
            driver = new ChromeDriver();
            driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
            // driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
            ngDriver = new NgWebDriver(driver);
            ngDriver.Navigate().GoToUrl(base_url);
        }

        [TestFixtureTearDown]
        public void TearDown()
        {
            try
            {
                driver.Quit();
            }
            catch (Exception) { } /* Ignore cleanup errors */
            Assert.AreEqual("", verificationErrors.ToString());
        }


        [Test]
        public void ShouldAddFriend()
        {
        	int timeout = 1000;
            StringAssert.AreEqualIgnoringCase(ngDriver.Title, "Angular JS Demo");
			String friendName = "John Doe";
    		int friendCount = ngDriver.FindElements(NgBy.Repeater("row in rows")).Count;
    		NgWebElement addnameBox = ngDriver.FindElement(NgBy.Model("addName"));
    		Assert.IsNotNull(addnameBox);
            ngDriver.Highlight(addnameBox,timeout);
    		addnameBox.SendKeys(friendName);

    		NgWebElement addButton = ngDriver.FindElement(NgBy.ButtonText("+ add"));
    		Assert.IsNotNull(addButton);
            ngDriver.Highlight(addButton,timeout);
            addButton.Click();
            
            Assert.AreEqual(1, ngDriver.FindElements(NgBy.Repeater("row in rows")).Count - friendCount );
    		NgWebElement addedFriendElement = ngDriver.FindElements(NgBy.CssContainingText("td.ng-binding",friendName)).First();
    		Assert.IsNotNull(addedFriendElement);
    		ngDriver.Highlight(addedFriendElement,timeout);
    		Console.Error.WriteLine("Added friend name: " + addedFriendElement.Text);
        }

        [Test]
        public void ShouldSearchAndDeleteFriend()
        {
        	ReadOnlyCollection<NgWebElement> names = ngDriver.FindElements(NgBy.RepeaterColumn("row in rows", "row"));
        	String nameString = names.First().Text;
        	NgWebElement searchBox  = ngDriver.FindElement(NgBy.Model("search"));
    		Assert.IsNotNull(searchBox);
            ngDriver.Highlight(searchBox,timeout);
        	searchBox.SendKeys(nameString);
        	ReadOnlyCollection<NgWebElement> elements = ngDriver.FindElements(NgBy.Repeater("row in rows"));
        	
        	foreach (NgWebElement element in elements.Where(op => op.Text.Contains( nameString))){
   				IWebElement deleteButton = element.FindElement(By.CssSelector("i.icon-trash"));     		
            	ngDriver.Highlight(deleteButton,timeout);
            	deleteButton.Click();
        	}
        	IWebElement clearSearchBox = searchBox.FindElement(By.XPath("..")).FindElement(By.CssSelector("i.icon-remove"));
    		Assert.IsNotNull(clearSearchBox);
            ngDriver.Highlight(clearSearchBox,timeout);
            clearSearchBox.Click();
        
        foreach (NgWebElement element in  ngDriver.FindElements(NgBy.Repeater("row in rows"))){
        	String currentName =  new NgWebElement(ngDriver, element).Evaluate("row").ToString();
      		Console.Error.WriteLine("Found name: " + currentName);
      		StringAssert.DoesNotMatch( currentName, nameString);
        }
                   }

    }
}