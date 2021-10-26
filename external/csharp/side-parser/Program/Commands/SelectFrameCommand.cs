using SeleniumParser.Driver;
using SeleniumParser.Models;

namespace SeleniumParser.Commands
{
	public class SelectFrameCommand : Command
	{
		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			Wait(1000 * 2);

			if (!comand.Target.ContainsText("="))
				return;

			var index = comand.Target.Split('=')[1].ToInt();
			Current.Driver.SwitchTo().Frame(frameIndex: index);
		}
	}
}
