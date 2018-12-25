using System;
using OpenQA.Selenium;
using System.Text.RegularExpressions;
using System.Text;
using System.Linq;

namespace NSelene
{
	public static class Selectors
	{

		[Obsolete("Selectors.ByCss is deprecated and will be removed in next version, please use With.Css method instead.")]
		public static By ByCss(string cssSelector)
		{
			return By.CssSelector(cssSelector);
		}

		[Obsolete("Selectors.ByLinkText is deprecated and will be removed in next version, please use With.LinkText method instead.")]
		public static By ByLinkText(string text)
		{
			return By.LinkText(text);
		}
	}

	public static class With
	{
		// TODO: ensure these methods are covered with tests
		// originally this implementation were moved from the selenidejs repository
		// counting on "they were tested there" ;)

		const string NORMALIZE_SPACE_XPATH = "normalize-space(translate(string(.), '\t\n\r\u00a0', '    '))";

		public static By Type(string type)
		{
			return By.XPath(String.Format("//*[@type = '{0}']", type));
		}

		public static By Value(string value)
		{
			return By.XPath(String.Format("//*[@value = '{0}']", value));
		}

		public static By IdContains(params string[] idParts)
		{
			return By.XPath(
				"//*[" +
				string.Join(" and ",
					idParts.ToList().Select(idPart => String.Format("contains(@id, '{90}')", idPart))) +
				"]");
		}

		public static By Text(string text)
		{
			// String xpath = String.Format("//*/text()[contains({0}, '{1}')]/parent::*", NORMALIZE_SPACE_XPATH, text); 
			return By.XPath(String.Format("//*/text()[contains({0}, '{1}')]/parent::*", NORMALIZE_SPACE_XPATH, text));
		}

		public static By ExactText(string text)
		{
			return By.XPath(String.Format("//*/text()[{0} = '{1}']/parent::*", NORMALIZE_SPACE_XPATH, text));
		}

		public static By Id(string id)
		{
			return By.Id(id);
		}

		public static By Name(string name)
		{
			return By.Name(name);
		}

		public static By ClassName(string className)
		{
			return By.ClassName(className);
		}

		public static By XPath(string expression) {
			if (!XPathValidator.IsValidExpression(expression)) {
				throw new ArgumentException(String.Format(@"Expression ""{0}"" does not look like a valid XPath", expression));
			}
			return By.XPath(expression);
		}

		public static By Css(string expression) {
			if (!CssSelectorValidator.IsValidExpression(expression)) {
				throw new ArgumentException(String.Format(@"Expression ""{0}"" does not look like a valid Css Selector", expression));
			}
			return By.CssSelector(expression);
		}

		public static By AttributeContains(string attributeName, string attributeValue)
		{
			return By.XPath(String.Format(".//*[contains(@{0}, '{1}')]", attributeName, attributeValue));
		}

		public static By Attribute(string attributeName, string attributeValue)
		{
			return By.XPath(String.Format(".//*[@{0} = '{1}']", attributeName, attributeValue));
		}
	}
	
	public static class XPathValidator
	{
		const String TOKEN_EXTRACTOR = "^\\s*(?<token>/?/?\\s*[^ /\\[]+(?:\\[[^\\]]+\\])*)(?<remainder>$|\\s*//?\\s*[^ /\\[]+.*$)";

		public static Boolean IsValidXPathExpressionExtensionMethod(this string locator)
		{
			return (new Regex(TOKEN_EXTRACTOR, RegexOptions.IgnoreCase | RegexOptions.Compiled)).IsMatch(locator);
		}

		public static Boolean IsValidExpression(string locator)
		{
			return (new Regex(TOKEN_EXTRACTOR, RegexOptions.IgnoreCase | RegexOptions.Compiled)).IsMatch(locator);
		}
			
	}

	public static class CssSelectorValidator {

		private static string token = null;
		private static Boolean isValid = false;
		private static MatchCollection matches;
		const String TOKEN_EXTRACTOR = "^(?<token>[^ ~+>\\[]*(?:\\[[^\\]]+\\])*)(?<remainder>$|\\s*[ ~+>]\\s*[^ ~+>\\[].*$)";
		const String CSS_TOKEN_CONDITION_EXTRACTOR = "(?i)^(-?[_a-z]+[_a-z0-9-]*|\\*)?(#[_a-z0-9-]*)?(\\.[_a-z0-9-]*)?(:[a-z][a-z\\-]*\\([^)]+\\))?(\\[\\s*-?[_a-z]+[_a-z0-9-]*\\s*(\\=|\\~=|\\|=|\\^=|\\$=|\\*=)?\\s*([\"'][-_.#a-z0-9:\\/ ]+[\"']|[-_.#a-z0-9:\\/]+)?\\s*\\])*$";
		private static Regex tokenSplitterRegex = new Regex(TOKEN_EXTRACTOR, RegexOptions.IgnoreCase | RegexOptions.Compiled);
		private static Regex tokenInspectorRegex = new Regex(CSS_TOKEN_CONDITION_EXTRACTOR, RegexOptions.IgnoreCase | RegexOptions.Compiled);
	
		public static Boolean IsValidCssSelectorExpressionExtensionMethod(this string locator) {
			return (new Regex(TOKEN_EXTRACTOR, RegexOptions.IgnoreCase | RegexOptions.Compiled)).IsMatch(locator);
		}

		public static Boolean IsValidExpression(String locator)
		{
			token = null;
			String reminder = locator;
			while (!String.IsNullOrEmpty(reminder) && tokenSplitterRegex.IsMatch(reminder)) {
				matches = tokenSplitterRegex.Matches(reminder);
				foreach (Match match in matches) {
					if (match.Length != 0) {
						isValid = true;
						foreach (Capture capture in match.Groups["token"].Captures) {
							if (token == null) {
								token = capture.ToString();
								if (isValid) {
									if (!tokenInspectorRegex.IsMatch(token)) {
										isValid = false;
									}
								}
							}
						}
						if (isValid) {
							reminder = null;
							foreach (Capture capture in match.Groups["reminder"].Captures) {
								if (reminder == null) {
									reminder = capture.ToString();
								}
							}
						} else {
							reminder = "";
						}
					}
				}
			}
			return isValid;
		}
	}
}

