using SeleniumParser.Models;

namespace SeleniumParser.Driver
{
	public interface ICommand
	{
		void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel command);
	}
}
