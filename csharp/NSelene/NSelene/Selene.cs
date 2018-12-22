using System;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Collections.Generic;

using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

using NSelene.Conditions;

namespace NSelene {

	// TODO: consider renaming Utils to Selene
	public static partial class Selene {

		private static String selectorKind = null;
		private static SeleneElement seleneElement = null;
		private static SeleneCollection seleneElementCollection = null;
		private static String selectorValue = null;
		private static Actions actions = null;

		private static MatchCollection matches;
		private static Regex regex;
		private const String findByCssSelectorAndInnerText = @"
 /**
 * Find elements by css selector and inner Textual content. Alternative to xpath locator //*[contains(text(),'...'))
 * Derived from: Protractor clientLibrary API
 * https://github.com/angular/protractor/blob/master/lib/clientsidescripts.js#L686
 * @param {string} cssSelector The css selector to send to document.querySelectorAll. Default is a 'body *'  
 * @param {string} innerText exact text or a serialized RegExp to search for
 *
 * @return last element in the array of matching elements (the innermost matching element is taken to the caller).
 */
var findByCssSelectorAndInnerText = function(сssSelector, innerText) {
  if (сssSelector == null || сssSelector == '') {
    сssSelector = 'body *';
  }
  if (debug != null && debug) {
    alert('cssSelector: ' +сssSelector);
  }
  if (debug != null && debug) {
	alert('text: ' + innerText );
  }
  if (innerText.indexOf('__REGEXP__') === 0) {
    var match = innerText.split('__REGEXP__')[1].match(/\/(.*)\/(.*)?/);
    innerText = new RegExp(match[1], match[2] || '');	  
  }

  var elements = document.querySelectorAll(сssSelector);
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText = element.textContent.replace(/\n/, ' ') || element.innerText.replace(/\n/, ' ') || element.getAttribute('placeholder') || '';
    var elementMatches = innerText instanceof RegExp ?
      innerText.test(elementText) :
      elementText.indexOf(innerText) > -1;
    if (elementMatches) {
      matches.push(element);
    }
  }
  var result = matches[matches.length - 1];
  if (debug != null && debug) {
	  if (result!= null ){
			 alert('Result: ' + /* result.outerHTML */ result.textContent );
	  } else {
		  alert('nothing found');		  
	  }
  }
  return result;
};

var debug = false;
var cssSelector = arguments[0];
var innerText = arguments[1];
return findByCssSelectorAndInnerText(cssSelector, innerText);
						";

		public static void SetWebDriver(IWebDriver driver) {
			PrivateConfiguration.SharedDriver.Value = driver;
		}

		public static IWebDriver GetWebDriver() {
			return PrivateConfiguration.SharedDriver.Value;
		}
		// need to learn to pass args.
		public static object ExecuteScript(string script) {
			return (GetWebDriver() as IJavaScriptExecutor).ExecuteScript(script);
		}

		public static SeleneElement S(By by) {
			return new SeleneElement(by);
		}

		public static SeleneElement S(string selectorValue, string selectorKind) {
			seleneElement = null;
			if (selectorKind != null) {
				switch (selectorKind) {
					case "css":
						seleneElement = S(By.CssSelector(selectorValue));
						break;
					case "xpath":
						seleneElement = S(By.XPath(selectorValue));
						break;
					case "text":
						seleneElement = ExecuteScript(findByCssSelectorAndInnerText) as SeleneElement;
						// seleneElement = S(By.XPath(String.Format("//*[contains(text(),'%s')]", selectorValue)));
						break;
					default:
						seleneElement = S(By.CssSelector(selectorValue));
						break;
				}
			} else {
				seleneElement = S(By.CssSelector(selectorValue));
			}
			return seleneElement;
		}

		public static SeleneElement S(string selector) {
			selectorKind = null;
			selectorValue = null ;
			seleneElement = null;
			regex = new Regex("^(?<kind>xpath|css|text) *= *(?<value>.*)$", RegexOptions.IgnoreCase | RegexOptions.Compiled);
			matches = regex.Matches(selector);
			foreach (Match match in matches) {
				if (match.Length != 0) {
					foreach (Capture capture in match.Groups["kind"].Captures) {
						if (selectorKind == null) {
							selectorKind = capture.ToString();
						}
					}
					foreach (Capture capture in match.Groups["value"].Captures) {
						if (selectorValue == null) {
							selectorValue = capture.ToString();
						}
					}
				}
			}
			if (selectorKind != null) {
				switch (selectorKind) {
					case "css":
						seleneElement = S(By.CssSelector(selectorValue));
						break;
					case "xpath":
						seleneElement = S(By.XPath(selectorValue));
						break;
					case "text":
						seleneElement = ExecuteScript(findByCssSelectorAndInnerText) as SeleneElement;
						// seleneElement = S(By.XPath(String.Format("//*[contains(text(),'%s')]", selectorValue)));
						break;
					default:
						seleneElement = S(By.CssSelector(selector));
						break;
				}
			} else {
				seleneElement = S(By.CssSelector(selector));
			}
			return seleneElement;
		}

		public static SeleneElement S(IWebElement pageFactoryElement, IWebDriver driver) {
			return new SeleneElement(pageFactoryElement, driver);
		}

		public static SeleneElement S(By locator, IWebDriver driver) {
			return new SeleneElement(locator, new SeleneDriver(driver));
		}

		public static SeleneElement S(string selector, IWebDriver driver) {
			// TODO: branch
			selectorKind = null;
			selectorValue = null;
			seleneElement = null;
			regex = new Regex("^(?<kind>xpath|css|text) *= *(?<value>.*)$", RegexOptions.IgnoreCase | RegexOptions.Compiled);
			matches = regex.Matches(selector);
			foreach (Match match in matches) {
				if (match.Length != 0) {
					foreach (Capture capture in match.Groups["kind"].Captures) {
						if (selectorKind == null) {
							selectorKind = capture.ToString();
						}
					}
					foreach (Capture capture in match.Groups["value"].Captures) {
						if (selectorValue == null) {
							selectorValue = capture.ToString();
						}
					}
				}
			}
			if (selectorKind != null) {
				switch (selectorKind) {
					case "css":
						seleneElement = S(By.CssSelector(selectorValue), driver);
						break;
					case "xpath":
						seleneElement = S(By.XPath(selectorValue), driver);
						break;
					case "text":
						IWebElement elementToWrap = ( driver as IJavaScriptExecutor ).ExecuteScript(findByCssSelectorAndInnerText, new object[] { null, selectorValue}) as IWebElement;
						seleneElement = new SeleneElement(elementToWrap, driver);
						// seleneElement = S(By.XPath(String.Format("//*[contains(text(),'%s')]", selectorValue)), driver);
						break;
					default:
						seleneElement = S(By.CssSelector(selectorValue), driver);
						break;
				}
			} else {
				seleneElement = S(By.CssSelector(selector), driver);
			}
			return seleneElement;
		}

		public static SeleneCollection SS(By locator) {
			return new SeleneCollection(locator);
		}

		public static SeleneCollection SS(string selector) {
			selectorKind = null;
			selectorValue = null;
			seleneElementCollection = null;
			regex = new Regex("^(?<kind>xpath|css|text) *= *(?<value>.*)$", RegexOptions.IgnoreCase | RegexOptions.Compiled);
			matches = regex.Matches(selector);
			foreach (Match match in matches) {
				if (match.Length != 0) {
					foreach (Capture capture in match.Groups["kind"].Captures) {
						if (selectorKind == null) {
							selectorKind = capture.ToString();
						}
					}
					foreach (Capture capture in match.Groups["value"].Captures) {
						if (selectorValue == null) {
							selectorValue = capture.ToString();
						}
					}
				}
			}
			if (selectorKind != null) {
				switch (selectorKind) {
					case "css":
						seleneElementCollection = SS(By.CssSelector(selectorValue));
						break;
					case "xpath":
						seleneElementCollection = SS(By.XPath(selectorValue));
						break;
					case "text":
						String xpath = String.Format("//*[contains(text(),'{0}')]", selectorValue);
						seleneElementCollection = SS(By.XPath(xpath));
						break;
					default:
						seleneElementCollection = SS(By.CssSelector(selector));
						break;
				}
			} else {
				seleneElementCollection = SS(By.CssSelector(selector));
			}
			return seleneElementCollection;
		}

		public static SeleneCollection SS(IList<IWebElement> pageFactoryElementsList, IWebDriver driver) {
			return new SeleneCollection(pageFactoryElementsList, driver);
		}

		public static SeleneCollection SS(By locator, IWebDriver driver) {
			return new SeleneCollection(locator, new SeleneDriver(driver));
		}

		public static SeleneCollection SS(string selector, IWebDriver driver) {
			selectorKind = null;
			selectorValue = null;
			seleneElementCollection = null;
			regex = new Regex("^(?<kind>xpath|css|text) *= *(?<value>.*)$", RegexOptions.IgnoreCase | RegexOptions.Compiled);
			matches = regex.Matches(selector);
			foreach (Match match in matches) {
				if (match.Length != 0) {
					foreach (Capture capture in match.Groups["kind"].Captures) {
						if (selectorKind == null) {
							selectorKind = capture.ToString();
						}
					}
					foreach (Capture capture in match.Groups["value"].Captures) {
						if (selectorValue == null) {
							selectorValue = capture.ToString();
						}
					}
				}
			}
			if (selectorKind != null) {
				switch (selectorKind) {
					case "css":
						seleneElementCollection = SS(By.CssSelector(selectorValue), driver);
						break;
					case "xpath":
						seleneElementCollection = SS(By.XPath(selectorValue), driver);
						break;
					case "text":
						String xpath = String.Format("//*[contains(text(),'{0}')]", selectorValue);
						seleneElementCollection = SS(By.XPath(xpath), driver);
						break;
					default:
						seleneElementCollection = SS(By.CssSelector(selector), driver);
						break;
				}
			} else {
				seleneElementCollection = SS(By.CssSelector(selector), driver);
			}
			return seleneElementCollection;
		}

		public static void Open(string url) {
			GoToUrl(url);
		}

		public static void GoToUrl(string url) {
			GetWebDriver().Navigate().GoToUrl(url);
		}

		// TODO: consider changing to static property
		public static string Url() {
			return GetWebDriver().Url;
		}

		public static Actions Actions {
			get {
				if (actions == null) {
					actions = new Actions(GetWebDriver());
				}
				return actions;
			}
		}

		public static IWebDriver WaitTo(Condition<IWebDriver> condition) {
			return WaitFor(GetWebDriver(), condition);
		}

		public static TResult WaitFor<TResult>(TResult sEntity, Condition<TResult> condition) {
			return WaitFor(sEntity, condition, Configuration.Timeout);
		}

		public static TResult WaitForNot<TResult>(TResult sEntity, Condition<TResult> condition) {
			return WaitForNot(sEntity, condition, Configuration.Timeout);
		}

		private static OpenQA.Selenium.Support.UI.SystemClock clock = null;

		public static TResult WaitFor<TResult>(TResult sEntity, Condition<TResult> condition, double timeout) {
			Exception lastException = null;
			if (clock == null) {
				clock = new OpenQA.Selenium.Support.UI.SystemClock();
			}
			var timeoutSpan = TimeSpan.FromSeconds(timeout);
			DateTime otherDateTime = clock.LaterBy(timeoutSpan);
			var ignoredExceptionTypes = new [] {
				typeof(WebDriverException),
				typeof(IndexOutOfRangeException),
				typeof(ArgumentOutOfRangeException)
			};
			while (true) {
				try {
					if (condition.Apply(sEntity)) {
						break;
					}
				} catch (Exception ex) {
					if (!ignoredExceptionTypes.Any(type => type.IsInstanceOfType(ex))) {
						throw;
					}
					lastException = ex;
				}
				if (!clock.IsNowBefore(otherDateTime)) {
					string text = string.Format("\nTimed out after {0} seconds \nwhile waiting entity with locator: {1} \nfor condition: "
                                                , timeoutSpan.TotalSeconds
                                                , sEntity
					              );
					text = text + condition;
					throw new WebDriverTimeoutException(text, lastException);
				}
				Thread.Sleep(TimeSpan.FromSeconds(Configuration.PollDuringWaits).Milliseconds);
			}
			return sEntity;
		}

		public static TResult WaitForNot<TResult>(TResult sEntity, Condition<TResult> condition, double timeout) {
			Exception lastException = null;
			if (clock == null) {
				clock = new OpenQA.Selenium.Support.UI.SystemClock();
			}
			var timeoutSpan = TimeSpan.FromSeconds(timeout);
			DateTime otherDateTime = clock.LaterBy(timeoutSpan);
//            var ignoredExceptionTypes = new [] { typeof(WebDriverException), typeof(IndexOutOfRangeException) };
			while (true) {
				try {
					if (!condition.Apply(sEntity)) {
						break;
					}
				} catch (Exception ex) {
					lastException = ex;
					break;
//                    if (!ignoredExceptionTypes.Any(type => type.IsInstanceOfType(ex)))
//                    {
//                        throw;
//                    }
				}
				if (!clock.IsNowBefore(otherDateTime)) {
					string text = string.Format("\nTimed out after {0} seconds \nwhile waiting entity with locator: {1}\nfor condition: not "
                                               , timeoutSpan.TotalSeconds, sEntity
					              );
					text = text + condition;
					throw new WebDriverTimeoutException(text, lastException);
				}
				Thread.Sleep(TimeSpan.FromSeconds(Configuration.PollDuringWaits).Milliseconds);
			}
			return sEntity;
		}

		//
		// Obsolete
		//

		[Obsolete("SetDriver is deprecated and will be removed in next version, please use Utils.SetWebDriver method instead.")]
		public static void SetDriver(IWebDriver driver) {
			PrivateConfiguration.SharedDriver.Value = driver;
		}

		[Obsolete("GetDriver is deprecated and will be removed in next version, please use Utils.GetWebDriver method instead.")]
		public static IWebDriver GetDriver() {
			return PrivateConfiguration.SharedDriver.Value;
		}

		[Obsolete("SActions method is deprecated and will be removed in next version, please use Utils.Actions property instead.")]
		public static Actions SActions() {
			return new Actions(GetWebDriver());
		}
	}

	[Obsolete("NSelene.Utils class is deprecated and will be removed in next version, please use NSelene.Selene class instead.")]
	public static class Utils {

		[Obsolete("SetDriver is deprecated and will be removed in next version, please use Selene.SetWebDriver method instead.")]
		public static void SetDriver(IWebDriver driver) {
			PrivateConfiguration.SharedDriver.Value = driver;
		}

		[Obsolete("Utils.SetWebDriver is deprecated and will be removed in next version, please use Selene.SetWebDriver method instead.")]
		public static void SetWebDriver(IWebDriver driver) {
			PrivateConfiguration.SharedDriver.Value = driver;
		}

		[Obsolete("Utils.GetDriver is deprecated and will be removed in next version, please use Selene.GetWebDriver method instead.")]
		public static IWebDriver GetDriver() {
			return PrivateConfiguration.SharedDriver.Value;
		}

		[Obsolete("Utils.GetWebDriver is deprecated and will be removed in next version, please use Selene.GetWebDriver method instead.")]
		public static IWebDriver GetWebDriver() {
			return PrivateConfiguration.SharedDriver.Value;
		}

		[Obsolete("Utils.ExecuteScript is deprecated and will be removed in next version, please use Selene.ExecuteScript method instead.")]
		public static object ExecuteScript(string script) {
			return (GetWebDriver() as IJavaScriptExecutor).ExecuteScript(script);
		}

		[Obsolete("Utils.S is deprecated and will be removed in next version, please use Selene.S method instead.")]
		public static SeleneElement S(By locator) {
			return new SeleneElement(locator);
		}

		[Obsolete("Utils.S is deprecated and will be removed in next version, please use Selene.S method instead.")]
		public static SeleneElement S(string cssSelector) {
			return S(By.CssSelector(cssSelector));
		}

		[Obsolete("Utils.S is deprecated and will be removed in next version, please use Selene.S method instead.")]
		public static SeleneElement S(By locator, IWebDriver driver) {
			return new SeleneElement(locator, new SeleneDriver(driver));
		}

		[Obsolete("Utils.S is deprecated and will be removed in next version, please use Selene.S method instead.")]
		public static SeleneElement S(string cssSelector, IWebDriver driver) {
			return S(By.CssSelector(cssSelector), driver);
		}

		[Obsolete("Utils.SS is deprecated and will be removed in next version, please use Selene.SS method instead.")]
		public static SeleneCollection SS(By locator) {
			return new SeleneCollection(locator);
		}

		[Obsolete("Utils.SS is deprecated and will be removed in next version, please use Selene.SS method instead.")]
		public static SeleneCollection SS(string cssSelector) {
			return SS(By.CssSelector(cssSelector));
		}

		[Obsolete("Utils.SS is deprecated and will be removed in next version, please use Selene.SS method instead.")]
		public static SeleneCollection SS(By locator, IWebDriver driver) {
			return new SeleneCollection(locator, new SeleneDriver(driver));
		}

		[Obsolete("Utils.SS is deprecated and will be removed in next version, please use Selene.SS method instead.")]
		public static SeleneCollection SS(string cssSelector, IWebDriver driver) {
			return SS(By.CssSelector(cssSelector), driver);
		}

		[Obsolete("Utils.Open is deprecated and will be removed in next version, please use Selene.Open method instead.")]
		public static void Open(string url) {
			GoToUrl(url);
		}

		[Obsolete("Utils.GoToUrl is deprecated and will be removed in next version, please use Selene.GoToUrl method instead.")]
		public static void GoToUrl(string url) {
			GetWebDriver().Navigate().GoToUrl(url);
		}

		[Obsolete("Utils.Url is deprecated and will be removed in next version, please use Selene.Url method instead.")]
		public static string Url()
		{
			return GetWebDriver().Url;
		}

		[Obsolete("SActions method is deprecated and will be removed in next version, please use Selene.Actions property instead.")]
		public static Actions SActions()
		{
			return new Actions(GetWebDriver());
		}
	}
}
