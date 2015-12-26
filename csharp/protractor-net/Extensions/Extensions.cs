using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using NUnit.Framework;
using OpenQA.Selenium;
using System.Collections.ObjectModel;
using System.Collections;
using System.Threading;
using System.Linq;

namespace Protractor.Extensions
{
    public static class Extensions
    {
    	private static string result;
        private static Regex theReg;	
    	private static MatchCollection theMatches;
        private static Match theMatch;
        private static Capture theCapture;

    	public static string FindMatch(this string element_text, string match_string = "(?<result>.+)$", string match_name = "result"){
        	result ="";
        	theReg = new Regex(match_string,
                                   RegexOptions.IgnoreCase | RegexOptions.IgnorePatternWhitespace | RegexOptions.Compiled);

            theMatches = theReg.Matches(element_text);
            foreach (Match theMatch in theMatches)
            {
                if (theMatch.Length != 0)
                {

                    foreach (Capture theCapture in theMatch.Groups[match_name].Captures)
                    {
                        result = theCapture.ToString();
                    }
                }
            }
            return result;
    	}
		public static void  Highlight(this NgWebDriver driver, IWebElement element, int highlight_timeout = 1000, int px = 3, string color = "yellow")
        {
			IWebDriver context = driver.WrappedDriver;
            ((IJavaScriptExecutor)context).ExecuteScript("arguments[0].style.border='" + px + "px solid " + color + "'", element);
            Thread.Sleep(highlight_timeout);
            ((IJavaScriptExecutor)context).ExecuteScript("arguments[0].style.border=''", element);
        }
    }
}