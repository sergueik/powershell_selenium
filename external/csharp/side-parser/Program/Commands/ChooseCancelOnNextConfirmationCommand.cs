using FluentAssertions;
using SeleniumParser.Driver;
using SeleniumParser.Models;

namespace SeleniumParser.Commands
{
	public class ChooseCancelOnNextConfirmationCommand : Command, INextCommand
	{
		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			var alert = Current.Driver.SwitchTo().Alert();

			alert
				.Should()
				.NotBeNull();

			Current.LastAlert = alert.Text;

			alert.Dismiss();
		}

	}
}
