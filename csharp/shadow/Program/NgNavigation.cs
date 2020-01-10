using System;

using OpenQA.Selenium;
using OpenQA.Selenium.Internal;
namespace ShadowDriver
{
    /// <summary>
    /// Provides a mechanism for navigating against an AngularJS application.
    /// </summary>
    public class NgNavigation : INavigation
    {
        private NgWebDriver ngDriver;
        private INavigation navigation;

        /// <summary>
        /// Creates a new instance of <see cref="NgNavigation"/> by wrapping a <see cref="INavigation"/> instance.
        /// </summary>
        /// <param name="ngDriver">The <see cref="NgWebDriver"/> in use.</param>
        /// <param name="navigation">The existing <see cref="INavigation"/> instance.</param>
        public NgNavigation(NgWebDriver ngDriver, INavigation navigation)
        {
            this.ngDriver = ngDriver;
            this.navigation = navigation;
        }

        /// <summary>
        /// Gets the wrapped <see cref="INavigation"/> instance.
        /// </summary>
        public INavigation WrappedNavigation
        {
            get { return this.navigation; }
        }

        #region INavigation Members

        /// <summary>
        /// Move back a single entry in the browser's history.
        /// </summary>
        public void Back()
        {
            this.ngDriver.WaitForAngular();
            this.navigation.Back();
        }

        /// <summary>
        /// Move a single "item" forward in the browser's history.
        /// </summary>
        public void Forward()
        {
            this.ngDriver.WaitForAngular();
            this.navigation.Forward();
        }

        /// <summary>
        /// Load a new web page in the current browser window.
        /// </summary>
        /// <param name="url">The URL to load.</param>
        public void GoToUrl(Uri url)
        {
            if (url == null)
            {
                throw new ArgumentNullException("url", "URL cannot be null.");
            }
            this.ngDriver.Url = url.ToString();
        }

        /// <summary>
        /// Load a new web page in the current browser window.
        /// </summary>
        /// <param name="url">The URL to load. It is best to use a fully qualified URL</param>
        public void GoToUrl(string url)
        {
            this.ngDriver.Url = url;
        }

        /// <summary>
        /// Browses to another page using in-page navigation
        /// </summary>
        /// <param name="selector">The selector housing an ng-app e.g. 'body'</param>
        /// <param name="url">The URL to load. It is best to use a fully qualified URL</param>
        public void SetLocation(string selector, string url)
        {
            IJavaScriptExecutor jsExecutor = this.ngDriver.WrappedDriver as IJavaScriptExecutor;
            jsExecutor.ExecuteScript(ClientSideScripts.SetLocation, new Object[] { selector, url });
        }


        /// <summary>
        /// Browse to another page using in-page navigation.
        /// </summary>
        /// <param name="url">The URL / path to load using the same syntax as '$location.url()'.</param>
        public void GoToLocation(string url)
        {
            this.ngDriver.Location = url;
        }
        /// <summary>
        /// Refreshes the current page.
        /// </summary>
        public void Refresh(){
          if (this.ngDriver.IgnoreSynchronization){
                this.navigation.Refresh();
            } else {
                this.ngDriver.Url = this.ngDriver.Url;
            }
        }
        #endregion
    }
}