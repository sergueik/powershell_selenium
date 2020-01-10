using System.Linq;
using System.Drawing;
using System.Collections.ObjectModel;

using OpenQA.Selenium;
using OpenQA.Selenium.Internal;

namespace ShadowDriver {

	public class ShadowWebElement : IWebElement, IWrapsElement {
		private ShadowWebDriver shadowDriver;
		private IWebElement element;

		public string GetProperty(string propertyName) {
			return this.WrappedElement.GetProperty(propertyName);
		}

		public ShadowWebElement(ShadowWebDriver shadowDriver, IWebElement element){
			this.shadowDriver = shadowDriver;
			this.element = element;
		}

		#region IWrapsElement Members
		public IWebElement WrappedElement {
			get { return this.element; }
		}

		#endregion

		#region IWebElement Members

		public bool Displayed {
			get {
				return this.element.Displayed;
			}
		}

		public bool Enabled {
			get {
				return this.element.Enabled;
			}
		}

		public Point Location {
			get {
				return this.element.Location;
			}
		}

		public bool Selected {
			get {
				return this.element.Selected;
			}
		}

		public Size Size {
			get {
				return this.element.Size;
			}
		}

		public string TagName {
			get {
				return this.element.TagName;
			}
		}

		public string Text {
			get {
				return this.element.Text;
			}
		}

		public ShadowWebDriver NgDriver {
			get { return shadowDriver; }
		}

		public void Clear()
		{
			this.element.Clear();
		}

		public void Click()
		{
			this.element.Click();
		}

		public string GetAttribute(string attributeName)
		{
			return this.element.GetAttribute(attributeName);
		}
		public string GetCssValue(string propertyName)
		{
			return this.element.GetCssValue(propertyName);
		}
		public void SendKeys(string text)
		{
			this.element.SendKeys(text);
		}
		public void Submit()
		{
			this.element.Submit();
		}
		public ShadowWebElement FindElement(By by)
		{
			if (by is JavaScriptBy) {
				((JavaScriptBy)by).RootElement = this.element;
			}
			return new ShadowWebElement(this.shadowDriver, this.element.FindElement(by));
		}
		public ReadOnlyCollection<ShadowWebElement> FindElements(By by)
		{
			if (by is JavaScriptBy) {
				((JavaScriptBy)by).RootElement = this.element;
			}
			return new ReadOnlyCollection<ShadowWebElement>(this.element.FindElements(by).Select(e => new ShadowWebElement(this.shadowDriver, e)).ToList());
		}
		IWebElement ISearchContext.FindElement(By by)
		{
			return this.FindElement(by);
		}

		ReadOnlyCollection<IWebElement> ISearchContext.FindElements(By by)
		{
			if (by is JavaScriptBy) {
				((JavaScriptBy)by).RootElement = this.element;
			}
			return new ReadOnlyCollection<IWebElement>(this.element.FindElements(by).Select(e => (IWebElement)new ShadowWebElement(this.shadowDriver, e)).ToList());
		}
		#endregion

	}
}