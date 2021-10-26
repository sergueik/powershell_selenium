using OpenQA.Selenium;
using SeleniumParser.Models;

namespace SeleniumParser.Delegates
{

	public delegate void DoubleClickCommandDelegate(SeleniumSideModel tests, SeleniumTestModel test,
		SeleniumCommandModel command, IWebElement element, ref bool preventDefault);

}
