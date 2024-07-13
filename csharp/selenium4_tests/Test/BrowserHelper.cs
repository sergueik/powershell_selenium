using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;

namespace Extensions {
	public static class BrowserHeler {
		// based on: https://github.com/shivampathak86/Selenium4.10.X/blob/main/CommanUtility.cs
		// Chrome-specific
		public static void WaitForFileDownloadCompletionInLocal(this IWebDriver driver, string filepath, int interval = 1000) {
			var wait = new WebDriverWait(driver, TimeSpan.FromSeconds(interval));
			wait.Until(dummy =>!Directory.GetFiles(filepath).Any(f => f.EndsWith(".crdownload")));
			// driver.WaitForCondition(dir => !Directory.GetFiles(filepath).Any(f => f.EndsWith(".crdownload")), interval); 
			
		}
	    
		// see also: 
		// https://stackoverflow.com/questions/6992993/selenium-c-sharp-webdriver-wait-until-element-is-present
	    public static bool VerifyElementTextPresent(this IWebDriver driver, IWebElement element, string text, int interval = 10) {
            var wait = new WebDriverWait(driver, TimeSpan.FromSeconds(interval));
            return wait.Until(dummy => element.Text.Contains(text));
        }
	}
}
		


