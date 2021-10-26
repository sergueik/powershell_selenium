using OpenQA.Selenium;
using SeleniumParser.Models;

namespace SeleniumParser.Delegates
{

	public delegate void ClickCommandDelegate(SeleniumSideModel tests, SeleniumTestModel test, 
		SeleniumCommandModel command, IWebElement element, ref bool preventDefault);

}
