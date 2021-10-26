using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;
using SeleniumParser.Models;
using System;
using System.Linq;
using System.Text;

namespace SeleniumParser.Driver
{
	public abstract class Command : ICommand
	{

		public Context Current { get; set; }

		public abstract void Perform(SeleniumSideModel tests, SeleniumTestModel test, SeleniumCommandModel comand);

		protected IWebElement SearchElement(SeleniumCommandModel sender)
		{
			foreach (var target in sender.Targets)
			{
				if (TryGetTargetElement(target, out IWebElement element) && (element != null))
					return element;
			}

			if (!string.IsNullOrEmpty(sender.Target))
			{
				var target = CreateTarget(sender.Target);
				if ((target != null) && TryGetTargetElement(target, out IWebElement element) && (element != null))
					return element;
			}

			var message = CreateMessage(sender);
			throw new Exception(message.ToString());
		}

		private bool TryGetTargetElement(string[] target, out IWebElement element)
		{
			if ((target.Length < 2) || !target[0].ContainsText("="))
			{
				element = null;
				return false;
			}

			element = SearchWebElement(target);
			return true;
		}

		private IWebElement SearchWebElement(string[] target)
		{
			var targetType = target[1];
			var targetValue = target[0].Split('=')[1];

			if (targetType.IsEquals("id"))
				return Current.Wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementExists(By.Id(targetValue)));

			if (targetType.IsEquals("name"))
				return Current.Wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementExists(By.Name(targetValue)));

			if (targetType.IsEquals("css:finder"))
				return Current.Wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementExists(By.CssSelector(targetValue)));

			if (targetType.IsEquals("xpath:attributes"))
				return Current.Wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementExists(By.XPath(targetValue)));

			if (targetType.IsEquals("xpath:idRelative"))
				return Current.Wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementExists(By.XPath(targetValue)));

			if (targetType.IsEquals("xpath:position"))
				return Current.Wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementExists(By.XPath(targetValue)));

			return null;
		}

		private string[] CreateTarget(string target)
		{
			string targetType = null;

			if (target.StartsWithText("css="))
				targetType = "css:finder";

			else if (target.StartsWithText("id="))
				targetType = "id";

			else if (target.StartsWithText("name="))
				targetType = "name";

			if (targetType == null)
				return null;

			return new[] { target, targetType };
		}

		private StringBuilder CreateMessage(SeleniumCommandModel sender)
		{
			var message = new StringBuilder();

			message.Append("Could not find component: ");
			message.Append(sender.Targets.FirstOrDefault());

			if (!string.IsNullOrEmpty(sender.Comment))
			{
				message.AppendLine();
				message.Append(sender.Comment);
			}

			return message;
		}

		protected void Wait(double delay)
		{
			var now = DateTime.Now;
			var wait = new WebDriverWait(Current.Driver, TimeSpan.FromMilliseconds(delay));
			wait.PollingInterval = TimeSpan.FromMilliseconds(1000);
			wait.Until(wd => (DateTime.Now - now) - TimeSpan.FromMilliseconds(delay) > TimeSpan.Zero);
		}

		// https://stackoverflow.com/questions/191940/c-sharp-generics-wont-allow-delegate-type-constraints
		// need C# 7.x
		protected T GetCustomEvent<T>() where T : Delegate
		{
			if (Current.Events.TryGetValue(typeof(T), out Delegate customEvent))
				return customEvent as T;
			return null;
		}

	}
}
