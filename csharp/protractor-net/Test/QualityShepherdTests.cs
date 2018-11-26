using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
// using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using System.Collections.ObjectModel;
using System.Collections;
using System.Threading;
using System.Linq;
using FluentAssertions;
using Protractor.Extensions;
//using System.Drawing;
//using System.Windows.Forms;

// origin: https://github.com/qualityshepherd/protractor_example

namespace Protractor.Test
{
	[TestFixture]
	public class QualityShepherdTests
	{
		private StringBuilder _verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private int highlight_timeout = 1000;
		private NgWebDriver ngDriver;
		private String base_url = "http://qualityshepherd.com/angular/friends/";

		[TestFixtureSetUp]
		public void SetUp()
		{
			driver = new ChromeDriver();
            // NOTE: SetScriptTimeout is obsolete
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
		public void ShouldAddFriend()
		{
			StringAssert.AreEqualIgnoringCase(ngDriver.Title, "Angular JS Demo");
			String friendName = "John Doe";
			int friendCount = ngDriver.FindElements(NgBy.Repeater("row in rows")).Count;
			NgWebElement addnameBox = ngDriver.FindElement(NgBy.Model("addName"));
			Assert.IsNotNull(addnameBox);
			ngDriver.Highlight(addnameBox, highlight_timeout);
			addnameBox.SendKeys(friendName);
			// add the friend
			NgWebElement addButton = ngDriver.FindElement(NgBy.ButtonText("+ add"));
			Assert.IsNotNull(addButton);
			ngDriver.Highlight(addButton, highlight_timeout);
			addButton.Click();
			// confirm the number of friends 
			Assert.AreEqual(1, ngDriver.FindElements(NgBy.Repeater("row in rows")).Count - friendCount);
			// find friend
			NgWebElement addedFriendElement = ngDriver.FindElements(NgBy.CssContainingText("td.ng-binding", friendName)).First();
			Assert.IsNotNull(addedFriendElement);
			ngDriver.Highlight(addedFriendElement, highlight_timeout);
			Console.Error.WriteLine("Added friend name: " + addedFriendElement.Text);
		}

		[Test]
		public void ShouldSearchAndDeleteFriend()
		{
			ReadOnlyCollection<NgWebElement> names = ngDriver.FindElements(NgBy.RepeaterColumn("row in rows", "row"));
			// pick random friend to remove
			Random random = new Random();
			int index = random.Next(0, names.Count - 1);
			String friendName = names.ElementAt(index).Text;
			ReadOnlyCollection<NgWebElement> friendRows = ngDriver.FindElements(NgBy.Repeater("row in rows"));
			// remove all friends with that name
			foreach (NgWebElement friendRow in friendRows.Where(op => op.Text.Contains(friendName))) {
				IWebElement deleteButton = friendRow.FindElement(By.CssSelector("i.icon-trash"));
				ngDriver.Highlight(deleteButton, highlight_timeout);
				deleteButton.Click();
			}
			// confirm search no longer finds any
			NgWebElement searchBox = ngDriver.FindElement(NgBy.Model("search"));
			Assert.IsNotNull(searchBox);
			ngDriver.Highlight(searchBox, highlight_timeout);
			searchBox.SendKeys(friendName);
			Action a = () => {
				var displayed = ngDriver.FindElement(NgBy.CssContainingText("td.ng-binding", friendName)).Displayed;
			};
			a.ShouldThrow<NullReferenceException>();
			// clear search inpout
			IWebElement clearSearchBox = searchBox.FindElement(By.XPath("..")).FindElement(By.CssSelector("i.icon-remove"));
			Assert.IsNotNull(clearSearchBox);
			ngDriver.Highlight(clearSearchBox, highlight_timeout);
			clearSearchBox.Click();
			// confirm name of remaining friends are different
			foreach (NgWebElement friendRow in ngDriver.FindElements(NgBy.Repeater("row in rows"))) {
				String otherFriendName = new NgWebElement(ngDriver, friendRow).Evaluate("row").ToString();
				Console.Error.WriteLine("Found name: " + otherFriendName);
				StringAssert.DoesNotMatch(otherFriendName, friendName);
			}
		}

	}
}