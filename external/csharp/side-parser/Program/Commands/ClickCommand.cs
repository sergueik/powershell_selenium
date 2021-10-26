using FluentAssertions;
using SeleniumParser.Delegates;
using SeleniumParser.Driver;
using SeleniumParser.Models;

namespace SeleniumParser.Commands
{
	public class ClickCommand : Command
	{
		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			var element = SearchElement(comand);

			element
				.Should()
				.NotBeNull();

			var preventDefault = false;

			var customEvent = GetCustomEvent<ClickCommandDelegate>();

			customEvent?.Invoke(tests, test, comand, element, ref preventDefault);

			if (!preventDefault)
				element.Click();
		}
	}
}
