using System;

using OpenQA.Selenium;
using OpenQA.Selenium.Internal;
namespace Protractor
{
    public class NgNavigation : INavigation
    {
        private NgWebDriver ngDriver;
        private INavigation navigation;

        /// <summary>
        ///
        /// </summary>    	
        public NgNavigation(NgWebDriver ngDriver, INavigation navigation)
        {
            this.ngDriver = ngDriver;
            this.navigation = navigation;
        }

        /// <summary>
        ///
        /// </summary>    	
        public INavigation WrappedNavigation
        {
            get { return this.navigation; }
        }

        #region INavigation Members

        /// <summary>
        ///
        /// </summary>    	
        public void Back()
        {
            this.navigation.Back();
        }

        /// <summary>
        ///
        /// </summary>    	
        public void Forward()
        {
            this.navigation.Forward();
        }

        /// <summary>
        ///
        /// </summary>    	
        public void GoToUrl(Uri url)
        {
            if (url == null)
            {
                throw new ArgumentNullException("url", "URL cannot be null.");
            }
            this.ngDriver.Url = url.ToString();
        }

        /// <summary>
        ///
        /// </summary>    	
        public void GoToUrl(string url)
        {
            this.ngDriver.Url = url;
        }

        /// <summary>
        ///
        /// </summary>    	
        public void SetLocation(string selector, string url)
        {
            IJavaScriptExecutor jsExecutor = this.ngDriver.WrappedDriver as IJavaScriptExecutor;
            jsExecutor.ExecuteScript(ClientSideScripts.SetLocation, new Object[]{selector, url});
        }

        /// <summary>
        ///
        /// </summary>    	
        public void Refresh()
        {
            this.navigation.Refresh();
        }

        #endregion
    }
}
