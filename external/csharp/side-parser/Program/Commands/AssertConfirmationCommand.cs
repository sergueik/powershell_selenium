using FluentAssertions;
using SeleniumParser.Driver;
using SeleniumParser.Models;

namespace SeleniumParser.Commands
{
	public class AssertConfirmationCommand : Command
	{
		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			Current.LastAlert
				.Should()
				.NotBeNull();

			Current.LastAlert
				.Should()
				.Be(comand.Target);
		}
	}
}
