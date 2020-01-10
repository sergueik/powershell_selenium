using System;
using System.Linq;
using System.Collections.Generic;
using System.Collections.ObjectModel;

using OpenQA.Selenium;
using OpenQA.Selenium.Internal;

namespace ShadowDriver
{
	public class ShadowWebDriver : IWebDriver, IWrapsDriver
	{
		private IWebDriver driver;
		private IJavaScriptExecutor jsExecutor;

		public ShadowWebDriver(IWebDriver driver)
		{
			if (!(driver is IJavaScriptExecutor)) {
				throw new NotSupportedException("The WebDriver instance must implement the IJavaScriptExecutor interface.");
			}
			this.driver = driver;
			this.jsExecutor = (IJavaScriptExecutor)driver;
		}
		#region IWrapsDriver Members
		public IWebDriver WrappedDriver {
			get { return this.driver; }
		}

		#endregion


		#region IWebDriver Members

		public string CurrentWindowHandle {
			get { return this.driver.CurrentWindowHandle; }
		}
		public string PageSource {
			get {
				return this.driver.PageSource;
			}
		}

		public string Title {
			get {
				return this.driver.Title;
			}
		}

		public string Url {
			get { 		return this.driver.Url; }
			set {
				this.driver.Url = value;}
		}

		public ReadOnlyCollection<string> WindowHandles {
			get { return this.driver.WindowHandles; }
		}

		public void Close()
		{
			this.driver.Close();
		}

		public IOptions Manage()
		{
			return this.driver.Manage();
		}

		public INavigation Navigate()
		{
			return this.driver.Navigate();
		}

		public void Quit()
		{
			this.driver.Quit();
		}

		public ITargetLocator SwitchTo()
		{
			return this.driver.SwitchTo();
		}

		public ShadowWebElement FindElement(By by)
		{
			return new ShadowWebElement(this, this.driver.FindElement(by));
		}
		public ReadOnlyCollection<ShadowWebElement> FindElements(By by)
		{
			return new ReadOnlyCollection<ShadowWebElement>(this.driver.FindElements(by).Select(e => new ShadowWebElement(this, e)).ToList());
		}

		IWebElement ISearchContext.FindElement(By by)
		{
			return this.FindElement(by);
		}

		ReadOnlyCollection<IWebElement> ISearchContext.FindElements(By by)
		{
			return new ReadOnlyCollection<IWebElement>(this.driver.FindElements(by).Select(e => (IWebElement)new ShadowWebElement(this, e)).ToList());
		}

		public void Dispose()
		{
			this.driver.Dispose();
		}

		#endregion

	}
}
