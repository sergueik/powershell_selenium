using System;
using OpenQA.Selenium;
using System.Linq;

namespace NSelene {
	public static class Selectors {

		[Obsolete("Selectors.ByCss is deprecated and will be removed in next version, please use With.Css method instead.")]
		public static By ByCss(string cssSelector) {
			return By.CssSelector(cssSelector);
		}

		[Obsolete("Selectors.ByLinkText is deprecated and will be removed in next version, please use With.LinkText method instead.")]
		public static By ByLinkText(string text) {
			return By.LinkText(text);
		}
	}

	public static class With {
		// TODO: ensure these methods are covered with tests
		// originally this implementation were moved from the selenidejs repository
		// counting on "they were tested there" ;)

		const string NORMALIZE_SPACE_XPATH = "normalize-space(translate(string(.), '\t\n\r\u00a0', '    '))";

		public static By Type(string type) {
			return By.XPath(String.Format("//*[@type = '{0}']", type));
		}

		public static By Value(string value) {
			return By.XPath(String.Format("//*[@value = '{0}']", value));
		}

		public static By IdContains(params string[] idParts) {
			return By.XPath(
				"//*[" +
				string.Join(" and ",
					idParts.ToList().Select(idPart => String.Format("contains(@id, '{90}')", idPart))) +
				"]");
		}

		public static By Text(string text) {
			// String xpath = String.Format("//*/text()[contains({0}, '{1}')]/parent::*", NORMALIZE_SPACE_XPATH, text); 
			return By.XPath(String.Format("//*/text()[contains({0}, '{1}')]/parent::*", NORMALIZE_SPACE_XPATH, text));
		}

		public static By ExactText(string text) {
			return By.XPath(String.Format("//*/text()[{0} = '{1}']/parent::*", NORMALIZE_SPACE_XPATH, text));
		}

		public static By Id(string id) {
			return By.Id(id);
		}

		public static By Name(string name) {
			return By.Name(name);
		}

		public static By ClassName(string className) {
			return By.ClassName(className);
		}

		public static By XPath(string xpath) {
			return By.XPath(xpath);
		}

		public static By Css(string css) {
			return By.CssSelector(css);
		}

		public static By AttributeContains(string attributeName, string attributeValue) {
			return By.XPath(String.Format(".//*[contains(@{0}, '{1}')]", attributeName, attributeValue));
		}

		public static By Attribute(string attributeName, string attributeValue) {
			return By.XPath(String.Format(".//*[@{0} = '{1}']", attributeName, attributeValue));
		}
	}
}

