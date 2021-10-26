using OpenQA.Selenium;
using SeleniumParser.Delegates;
using SeleniumParser.Driver;
using SeleniumParser.Models;
using System;
using System.IO;

namespace SeleniumParser
{
	public class Parser
	{

		public TypeCommandDelegate OnTypeCommand { get; set; }

		public SendKeysCommandDelegate OnSendKeysCommand { get; set; }

		public ClickCommandDelegate OnClickCommand { get; set; }

		public DoubleClickCommandDelegate OnDoubleClickCommand { get; set; }

		public void ParseTests(string sideFile, IWebDriver driver)
		{
			var tests = ConvertSideFileToModel(sideFile);
			foreach (var test in tests.Tests)
			{
				var context = CreateContext(driver);
				foreach (var command in test.Commands)
					PerformCommand(tests, context, test, command);
			}
		}

		private Context CreateContext(IWebDriver driver)
		{
			var context = new Context(driver);
			AddContextEvent(context, OnTypeCommand);
			AddContextEvent(context, OnSendKeysCommand);
			AddContextEvent(context, OnClickCommand);
			AddContextEvent(context, OnDoubleClickCommand);
			return context;
		}
		
		// https://stackoverflow.com/questions/191940/c-sharp-generics-wont-allow-delegate-type-constraints
		// need C# 7.x
		private void AddContextEvent<T>(Context context, T onCommand) where T : Delegate
		{
			if (onCommand != null)
				context.Events.Add(typeof(T), onCommand);
		}

		private void PerformCommand(SeleniumSideModel tests, Context context, SeleniumTestModel test, SeleniumCommandModel command)
		{
			var current = CommandFactory.Create(context, command.Command);
			if (!(current is INextCommand))
				current.Perform(tests, test, command);
			if (context.LastCommand is INextCommand)
				context.LastCommand.Perform(tests, test, command);
			context.LastCommand = current;
		}

		public void ParseOneTestByBrowserInstance(string sideFile, Func<IWebDriver> driverConstructor)
		{
			var tests = ConvertSideFileToModel(sideFile);
			foreach (var test in tests.Tests)
			{
				using (var driver = driverConstructor())
				{
					var context = CreateContext(driver);
					foreach (var command in test.Commands)
						PerformCommand(tests, context, test, command);
				}
			}
		}

		private SeleniumSideModel ConvertSideFileToModel(string sideFile)
		{
			using (var arquivo = new StreamReader(sideFile))
				return Newtonsoft.Json.JsonConvert.DeserializeObject<SeleniumSideModel>(arquivo.ReadToEnd());
		}

		public void ParseAllTestsOnSameBrowserInstance(string sideFile, Func<IWebDriver> driverConstructor)
		{
			var tests = ConvertSideFileToModel(sideFile);
			using (var driver = driverConstructor())
			{
				var context = CreateContext(driver);
				foreach (var test in tests.Tests)
				{
					foreach (var command in test.Commands)
						PerformCommand(tests, context, test, command);
				}
			}
		}

	}
}
