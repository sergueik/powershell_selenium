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
        private IWebDriver _driver;
        private int _highlight_timeout = 1000;
        private NgWebDriver _ngDriver;
        private String _base_url = "http://qualityshepherd.com/angular/friends/";

        [TestFixtureSetUp]
        public void SetUp()
        {
            _driver = new ChromeDriver();
            _driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
            // driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
            _ngDriver = new NgWebDriver(_driver);
            _ngDriver.Navigate().GoToUrl(_base_url);
        }

        [TestFixtureTearDown]
        public void TearDown()
        {
            try
            {
                _driver.Quit();
            }
            catch (Exception) { } /* Ignore cleanup errors */
            Assert.AreEqual("", _verificationErrors.ToString());
        }


        [Test]
        public void ShouldAddFriend()
        {
            int timeout = 1000;
            StringAssert.AreEqualIgnoringCase(_ngDriver.Title, "Angular JS Demo");
            String friendName = "John Doe";
            int friendCount = _ngDriver.FindElements(NgBy.Repeater("row in rows")).Count;
            NgWebElement addnameBox = _ngDriver.FindElement(NgBy.Model("addName"));
            Assert.IsNotNull(addnameBox);
            _ngDriver.Highlight(addnameBox, _highlight_timeout);
            addnameBox.SendKeys(friendName);
            // add the friend
            NgWebElement addButton = _ngDriver.FindElement(NgBy.ButtonText("+ add"));
            Assert.IsNotNull(addButton);
            _ngDriver.Highlight(addButton, _highlight_timeout);
            addButton.Click();
            // confirm the number of friends 
            Assert.AreEqual(1, _ngDriver.FindElements(NgBy.Repeater("row in rows")).Count - friendCount);
            // find friend
            NgWebElement addedFriendElement = _ngDriver.FindElements(NgBy.CssContainingText("td.ng-binding", friendName)).First();
            Assert.IsNotNull(addedFriendElement);
            _ngDriver.Highlight(addedFriendElement, _highlight_timeout);
            Console.Error.WriteLine("Added friend name: " + addedFriendElement.Text);
        }

        [Test]
        public void ShouldSearchAndDeleteFriend()
        {
            ReadOnlyCollection<NgWebElement> names = _ngDriver.FindElements(NgBy.RepeaterColumn("row in rows", "row"));
            // pick random friend to remove
            Random random = new Random();
            int index = random.Next(0, names.Count - 1);
            String friendName = names.ElementAt(index).Text;
            ReadOnlyCollection<NgWebElement> friendRows = _ngDriver.FindElements(NgBy.Repeater("row in rows"));
            // remove all friends with that name
            foreach (NgWebElement friendRow in friendRows.Where(op => op.Text.Contains(friendName)))
            {
                IWebElement deleteButton = friendRow.FindElement(By.CssSelector("i.icon-trash"));
                _ngDriver.Highlight(deleteButton, _highlight_timeout);
                deleteButton.Click();
            }
            // confirm search no longer finds any
            NgWebElement searchBox = _ngDriver.FindElement(NgBy.Model("search"));
            Assert.IsNotNull(searchBox);
            _ngDriver.Highlight(searchBox, _highlight_timeout);
            searchBox.SendKeys(friendName);
            Action a = () =>
            {
                var displayed = _ngDriver.FindElement(NgBy.CssContainingText("td.ng-binding", friendName)).Displayed;
            };
            a.ShouldThrow<NullReferenceException>();
            // clear search inpout
            IWebElement clearSearchBox = searchBox.FindElement(By.XPath("..")).FindElement(By.CssSelector("i.icon-remove"));
            Assert.IsNotNull(clearSearchBox);
            _ngDriver.Highlight(clearSearchBox, _highlight_timeout);
            clearSearchBox.Click();
            // confirm name of remaining friends are different
            foreach (NgWebElement friendRow in _ngDriver.FindElements(NgBy.Repeater("row in rows")))
            {
                String otherFriendName = new NgWebElement(_ngDriver, friendRow).Evaluate("row").ToString();
                Console.Error.WriteLine("Found name: " + otherFriendName);
                StringAssert.DoesNotMatch(otherFriendName, friendName);
            }
        }

    }
}