﻿using System;
using System.Linq;
using System.Collections.Generic;
using System.Collections.ObjectModel;

using OpenQA.Selenium;
using OpenQA.Selenium.Internal;

namespace ShadowDriver
{
	/// <summary>
	/// Provides a mechanism to write tests against an AngularJS application.
	/// </summary>
	public class NgWebDriver : IWebDriver, IWrapsDriver
	{
		private const string AngularDeferBootstrap = "NG_DEFER_BOOTSTRAP!";
		private IWebDriver driver;
		private IJavaScriptExecutor jsExecutor;
		private string rootElement;
		private NgModule[] mockModules;

		/// <summary>
		/// Creates a new instance of <see cref="NgWebDriver"/> by wrapping a <see cref="IWebDriver"/> instance.
		/// </summary>
		/// <param name="driver">The configured webdriver instance.</param>
		/// <param name="mockModules">
		/// The modules to load before Angular whenever Url setter or Navigate().GoToUrl() is called.
		/// </param>
		public NgWebDriver(IWebDriver driver, params NgModule[] mockModules)
			: this(driver, "body", mockModules)
		{
		}

		/// <summary>
		/// Creates a new instance of <see cref="NgWebDriver"/> by wrapping a <see cref="IWebDriver"/> instance.
		/// </summary>
		/// <param name="driver">The configured webdriver instance.</param>
		/// <param name="rootElement">
		/// The CSS selector for an element on which to find Angular.
		/// <para/>
		/// This is usually 'body' but if your ng-app is on a subsection of the page it may be a subelement.
		/// </param>
		/// <param name="mockModules">
		/// The modules to load before Angular whenever Url setter or Navigate().GoToUrl() is called.
		/// </param>
		public NgWebDriver(IWebDriver driver, string rootElement, params NgModule[] mockModules)
		{
			if (!(driver is IJavaScriptExecutor)) {
				throw new NotSupportedException("The WebDriver instance must implement the IJavaScriptExecutor interface.");
			}
			this.driver = driver;
			this.jsExecutor = (IJavaScriptExecutor)driver;
			this.rootElement = rootElement;
			this.mockModules = mockModules;
		}

		#region IWrapsDriver Members

		/// <summary>
		/// Gets the wrapped <see cref="IWebDriver"/> instance.
		/// <para/>
		/// Use this to interact with pages that do not contain Angular (such as a log-in screen).
		/// </summary>
		public IWebDriver WrappedDriver {
			get { return this.driver; }
		}

		#endregion

		/// <summary>
		/// Gets the CSS selector for an element on which to find Angular.
		/// <para/>
		/// This is usually 'body' but if your ng-app is on a subsection of the page it may be a subelement.
		/// </summary>
		public string RootElement {
			get { return this.rootElement; }
		}

		/// <summary>
		/// If true, ShadowDriver will not attempt to synchronize with the page before performing actions.
		/// This can be harmful because ShadowDriver will not wait until $timeouts and $http calls have been processed,
		/// which can cause tests to become flaky.
		/// This should be used only when necessary, such as when a page continuously polls an API using $timeout.
		/// </summary>
		public bool IgnoreSynchronization { get; set; }

		#region IWebDriver Members

		/// <summary>
		/// Gets the current window handle, which is an opaque handle to this
		/// window that uniquely identifies it within this driver instance.
		/// </summary>
		public string CurrentWindowHandle {
			get { return this.driver.CurrentWindowHandle; }
		}

		/// <summary>
		/// Gets the source of the page last loaded by the browser.
		/// </summary>
		public string PageSource {
			get {
				this.WaitForAngular();
				return this.driver.PageSource;
			}
		}

		/// <summary>
		/// Gets the title of the current browser window.
		/// </summary>
		public string Title {
			get {
				this.WaitForAngular();
				return this.driver.Title;
			}
		}

		public Boolean TestForAngular()
		{
			// Make sure the page is an Angular page.
			try {
				int isAngularApp = 0;
				Int32.TryParse(this.jsExecutor.ExecuteAsyncScript(ClientSideScripts.TestForAngular, 60).ToString(), out isAngularApp);
				if (isAngularApp != 0) {
					return true;
				} else {
					return false;
				}
			} catch (WebDriverTimeoutException) {
				return false;
			}
		}

		/// <summary>
		/// Gets or sets the URL the browser is currently displaying.
		/// </summary>
		public string Url {
			get {
				this.WaitForAngular();
                string browserName = null;
				IHasCapabilities hcDriver = this.driver as IHasCapabilities;
				if (hcDriver != null && hcDriver.Capabilities.HasCapability("browserName"))
                {
                    browserName = hcDriver.Capabilities.GetCapability("browserName").ToString();
                }
				if (browserName != null && (browserName == "internet explorer" || browserName == "MicrosoftEdge" || browserName.ToLower() == "safari")) {
					// 'this.driver.Url' did not work on IE for some time
					return this.jsExecutor.ExecuteScript(ClientSideScripts.GetLocationAbsUrl, this.rootElement) as string;
				} else {
					return this.driver.Url;
				}
			}
			set {
				// Reset URL
				this.driver.Url = "about:blank";
                string browserName = null;
				IHasCapabilities hcDriver = this.driver as IHasCapabilities;
				if (hcDriver != null && hcDriver.Capabilities.HasCapability("browserName"))
                {
                    browserName = hcDriver.Capabilities.GetCapability("browserName").ToString();
                }
				if (browserName != null && (browserName == "internet explorer" || browserName == "MicrosoftEdge" || browserName.ToLower() == "safari")) {
					// Internet Explorer, Edge, PhantomJS
					this.jsExecutor.ExecuteScript("window.name += '" + AngularDeferBootstrap + "';");
					this.driver.Url = value;
				} else {
					// Chrome & Firefox
					this.jsExecutor.ExecuteScript("window.name += '" + AngularDeferBootstrap + "'; window.location.href = '" + value + "';");
				}

				if (!this.IgnoreSynchronization) {
					// Make sure the page is an Angular page.
					int isAngularApp = 0;
					Int32.TryParse(this.jsExecutor.ExecuteAsyncScript(ClientSideScripts.TestForAngular, 60).ToString(), out isAngularApp);
					if (isAngularApp != 0) {
						// At this point, Angular will pause for us, until angular.resumeBootstrap is called.

						// Register extra modules
						foreach (NgModule ngModule in this.mockModules) {
							this.jsExecutor.ExecuteScript(ngModule.Script);
						}
						// Resume Angular bootstrap
						this.jsExecutor.ExecuteScript(ClientSideScripts.ResumeAngularBootstrap,
							String.Join(",", this.mockModules.Select(m => m.Name).ToArray()));
					} else {
						throw new InvalidOperationException(
							String.Format("Angular could not be found on the page '{0}'", value));
					}
				}
			}
		}

		/// <summary>
		/// Gets the window handles of open browser windows.
		/// </summary>
		public ReadOnlyCollection<string> WindowHandles {
			get { return this.driver.WindowHandles; }
		}

		/// <summary>
		/// Close the current window, quitting the browser if it is the last window currently open.
		/// </summary>
		public void Close()
		{
			this.driver.Close();
		}

		/// <summary>
		/// Instructs the driver to change its settings.
		/// </summary>
		/// <returns>
		/// An <see cref="IOptions"/> object allowing the user to change the settings of the driver.
		/// </returns>
		public IOptions Manage()
		{
			return this.driver.Manage();
		}

		/// <summary>
		/// Instructs the driver to navigate the browser to another location.
		/// </summary>
		/// <returns>
		/// An <see cref="INavigation"/> object allowing the user to access
		/// the browser's history and to navigate to a given URL.
		/// </returns>
		public INavigation Navigate()
		{
			return new NgNavigation(this, this.driver.Navigate());
		}

		/// <summary>
		/// Quits this driver, closing every associated window.
		/// </summary>
		public void Quit()
		{
			this.driver.Quit();
		}

		/// <summary>
		/// Instructs the driver to send future commands to a different frame or window.
		/// </summary>
		/// <returns>
		/// An <see cref="ITargetLocator"/> object which can be used to select a frame or window.
		/// </returns>
		public ITargetLocator SwitchTo()
		{
			return this.driver.SwitchTo();
		}

		/// <summary>
		/// Finds the first <see cref="NgWebElement"/> using the given mechanism.
		/// </summary>
		/// <param name="by">The locating mechanism to use.</param>
		/// <returns>The first matching <see cref="NgWebElement"/> on the current context.</returns>
		/// <exception cref="NoSuchElementException">If no element matches the criteria.</exception>
		public NgWebElement FindElement(By by)
		{
			this.WaitForAngular();
			return new NgWebElement(this, this.driver.FindElement(by));
		}

		/// <summary>
		/// Finds all <see cref="NgWebElement"/>s within the current context
		/// using the given mechanism.
		/// </summary>
		/// <param name="by">The locating mechanism to use.</param>
		/// <returns>
		/// A <see cref="ReadOnlyCollection{T}"/> of all <see cref="NgWebElement"/>s
		/// matching the current criteria, or an empty list if nothing matches.
		/// </returns>
		public ReadOnlyCollection<NgWebElement> FindElements(By by)
		{
			this.WaitForAngular();
			return new ReadOnlyCollection<NgWebElement>(this.driver.FindElements(by).Select(e => new NgWebElement(this, e)).ToList());
		}

		IWebElement ISearchContext.FindElement(By by)
		{
			return this.FindElement(by);
		}

		ReadOnlyCollection<IWebElement> ISearchContext.FindElements(By by)
		{
			this.WaitForAngular();
			return new ReadOnlyCollection<IWebElement>(this.driver.FindElements(by).Select(e => (IWebElement)new NgWebElement(this, e)).ToList());
		}

		/// <summary>
		/// Performs application-defined tasks associated with freeing,
		/// releasing, or resetting unmanaged resources.
		/// </summary>
		public void Dispose()
		{
			this.driver.Dispose();
		}

		#endregion

		/// <summary>
		/// Gets or sets the location for in-page navigation using the same syntax as '$location.url()'.
		/// </summary>
		public string Location {
			get {
				this.WaitForAngular();
				return this.jsExecutor.ExecuteScript(ClientSideScripts.GetLocation, this.rootElement) as string;
			}
			set {
				this.WaitForAngular();
				this.jsExecutor.ExecuteScript(ClientSideScripts.SetLocation, this.rootElement, value);
			}
		}

		internal void WaitForAngular()
		{
			if (!this.IgnoreSynchronization) {
				this.jsExecutor.ExecuteAsyncScript(ClientSideScripts.WaitForAngular, this.rootElement);
			}
		}

		internal void WaitForAllAngular2()
		{
			if (!this.IgnoreSynchronization) {
				this.jsExecutor.ExecuteAsyncScript(ClientSideScripts.WaitForAllAngular2);
			}
		}
	}
}
