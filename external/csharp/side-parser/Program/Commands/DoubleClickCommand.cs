using FluentAssertions;
using SeleniumParser.Delegates;
using SeleniumParser.Driver;
using SeleniumParser.Models;

namespace SeleniumParser.Commands
{
	public class DoubleClickCommand : Command
	{
		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			var element = SearchElement(comand);

			element
				.Should()
				.NotBeNull();

			var preventDefault = false;

			var customEvent = GetCustomEvent<DoubleClickCommandDelegate>();

			customEvent?.Invoke(tests, test, comand, element, ref preventDefault);

			if (!preventDefault)
				Current.Actions.DoubleClick(element).Perform();
		}
	}
}
