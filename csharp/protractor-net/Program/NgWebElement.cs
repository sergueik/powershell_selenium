using System.Linq;
using System.Drawing;
using System.Collections.ObjectModel;

using OpenQA.Selenium;
using OpenQA.Selenium.Internal;

namespace Protractor
{
    public class NgWebElement : IWebElement, IWrapsElement
    {
        private NgWebDriver ngDriver;
        private IWebElement element;

        public NgWebElement(NgWebDriver ngDriver, IWebElement element)
        {
            this.ngDriver = ngDriver;
            this.element = element;
        }

        #region IWrapsElement Members

        public IWebElement WrappedElement
        {
            get { return this.element; }
        }

        #endregion

        #region IWebElement Members

        /// <summary>
        ///
        /// </summary>    	
        public bool Displayed
        {
            get
            {
                this.ngDriver.WaitForAngular();
                return this.element.Displayed;
            }
        }

        /// <summary>
        ///
        /// </summary>    	
        public bool Enabled
        {
            get
            {
                this.ngDriver.WaitForAngular();
                return this.element.Enabled;
            }
        }

        /// <summary>
        ///
        /// </summary>    	
        public Point Location
        {
            get
            {
                this.ngDriver.WaitForAngular();
                return this.element.Location;
            }
        }

        /// <summary>
        ///
        /// </summary>    	
        public bool Selected
        {
            get
            {
                this.ngDriver.WaitForAngular();
                return this.element.Selected;
            }
        }

        /// <summary>
        ///
        /// </summary>    	
        public Size Size
        {
            get
            {
                this.ngDriver.WaitForAngular();
                return this.element.Size;
            }
        }

        /// <summary>
        ///
        /// </summary>    	
        public string TagName
        {
            get
            {
                this.ngDriver.WaitForAngular();
                return this.element.TagName;
            }
        }

        /// <summary>
        ///
        /// </summary>    	
        public string Text
        {
            get
            {
                this.ngDriver.WaitForAngular();
                return this.element.Text;
            }
        }

        /// <summary>
        ///
        /// </summary>    	
        public void Clear()
        {
            this.ngDriver.WaitForAngular();
            this.element.Clear();
        }

        /// <summary>
        ///
        /// </summary>    	
        public void Click()
        {
            this.ngDriver.WaitForAngular();
            this.element.Click();
        }

        /// <summary>
        ///
        /// </summary>    	
        public string GetAttribute(string attributeName)
        {
            this.ngDriver.WaitForAngular();
            return this.element.GetAttribute(attributeName);
        }

        /// <summary>
        ///
        /// </summary>    	
        public string GetCssValue(string propertyName)
        {
            this.ngDriver.WaitForAngular();
            return this.element.GetCssValue(propertyName);
        }

        /// <summary>
        ///
        /// </summary>    	
        public void SendKeys(string text)
        {
            this.ngDriver.WaitForAngular();
            this.element.SendKeys(text);
        }

        /// <summary>
        ///
        /// </summary>    	
        public void Submit()
        {
            this.ngDriver.WaitForAngular();
            this.element.Submit();
        }

        /// <summary>
        ///
        /// </summary>    	
        public NgWebElement FindElement(By by)
        {
            if (by is JavaScriptBy)
            {
                ((JavaScriptBy)by).RootElement = this.element;
            }
            this.ngDriver.WaitForAngular();
            return new NgWebElement(this.ngDriver, this.element.FindElement(by));
        }

        /// <summary>
        ///
        /// </summary>    	
        public ReadOnlyCollection<NgWebElement> FindElements(By by)
        {
            if (by is JavaScriptBy)
            {
                ((JavaScriptBy)by).RootElement = this.element;
            }
            this.ngDriver.WaitForAngular();
            return new ReadOnlyCollection<NgWebElement>(this.element.FindElements(by).Select(e => new NgWebElement(this.ngDriver, e)).ToList());
        }

        /// <summary>
        ///
        /// </summary>    	
        IWebElement ISearchContext.FindElement(By by)
        {
            return this.FindElement(by);
        }

        /// <summary>
        ///
        /// </summary>    	
        ReadOnlyCollection<IWebElement> ISearchContext.FindElements(By by)
        {
            if (by is JavaScriptBy)
            {
                ((JavaScriptBy)by).RootElement = this.element;
            }
            this.ngDriver.WaitForAngular();
            return new ReadOnlyCollection<IWebElement>(this.element.FindElements(by).Select(e => (IWebElement)new NgWebElement(this.ngDriver, e)).ToList());
        }

        #endregion

        /// <summary>
        ///
        /// </summary>    	
        public object Evaluate(string expression)
        {
            this.ngDriver.WaitForAngular();
            return ((IJavaScriptExecutor)this.ngDriver.WrappedDriver).ExecuteScript(ClientSideScripts.Evaluate, this.element, expression);
        }
    }
}
