using FluentAssertions;
using SeleniumParser.Delegates;
using SeleniumParser.Driver;
using SeleniumParser.Models;

namespace SeleniumParser.Commands
{
	public class TypeCommand : Command
	{
		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			var element = SearchElement(comand);

			element
				.Should()
				.NotBeNull();

			var preventDefault = false;

			var customEvent = GetCustomEvent<TypeCommandDelegate>();

			var value = comand.Value;

			customEvent?.Invoke(tests, test, comand, element, ref value, ref preventDefault);

			if (!preventDefault)
				element.SendKeys(value);
		}
	}
}
