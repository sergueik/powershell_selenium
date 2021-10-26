using System.Drawing;
using SeleniumParser.Driver;
using SeleniumParser.Models;

namespace SeleniumParser.Commands
{
	public class SetWindowSizeCommand : Command
	{
		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			var size = comand.Target.Split('x');
			if (size.Length > 1)
				Current.Driver.Manage().Window.Size = new Size(size[0].ToInt(), size[1].ToInt());
		}
	}
}
