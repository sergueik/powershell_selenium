using OpenQA.Selenium;
using SeleniumParser.Models;

namespace SeleniumParser.Delegates
{

	public delegate void SendKeysCommandDelegate(SeleniumSideModel tests, SeleniumTestModel test,
		SeleniumCommandModel command, IWebElement element, ref string value, ref bool preventDefault);

}
