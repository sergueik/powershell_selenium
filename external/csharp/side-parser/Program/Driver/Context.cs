using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using System;
using System.Collections.Generic;

namespace SeleniumParser.Driver
{
	public class Context
	{

		public IWebDriver Driver { get; }

		public WebDriverWait Wait { get; }

		public Actions Actions { get; }

		public ICommand LastCommand { get; set; }

		public string LastAlert { get; set; }

		public IDictionary<Type, Delegate> Events { get; }

		public Context(IWebDriver driver)
		{
			Driver = driver;
			Wait = new WebDriverWait(Driver, TimeSpan.FromSeconds(10));
			Actions = new Actions(driver);
			Events = new Dictionary<Type, Delegate>();
		}

	}
}
