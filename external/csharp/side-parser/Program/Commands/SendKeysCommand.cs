using FluentAssertions;
using OpenQA.Selenium;
using System.Text;
using SeleniumParser.Driver;
using SeleniumParser.Models;
using SeleniumParser.Delegates;

namespace SeleniumParser.Commands
{
	public class SendKeysCommand : Command
	{
		public override void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand)
		{
			var element = SearchElement(comand);

			element
				.Should()
				.NotBeNull();

			var preventDefault = false;

			var customEvent = GetCustomEvent<SendKeysCommandDelegate>();

			var value = FindKeys(comand);

			customEvent?.Invoke(tests, test, comand, element, ref value, ref preventDefault);

			if (!preventDefault)
				element.SendKeys(value);
		}

		private string FindKeys(SeleniumCommandModel sender)
		{
			var teclas = new StringBuilder();

			if (sender.Value.ContainsText("${KEY_ENTER}"))
				teclas.Append(Keys.Enter);

			return teclas.ToString();
		}

	}
}
