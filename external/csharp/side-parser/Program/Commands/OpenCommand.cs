using SeleniumParser.Driver;
using SeleniumParser.Models;

namespace SeleniumParser.Commands
{
	public class OpenCommand : Command
	{

		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			Current.Driver.Navigate().GoToUrl(tests.Url + comand.Target);
		}

	}
}
