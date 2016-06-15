// origin: https://gist.github.com/jmflaherty/37198911556233a7d736

using System;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using Microsoft.Activities.UnitTesting;
using System.IO;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.PhantomJS;

namespace WebTester
{
    public static class Extensions
    {
        /// <summary>
        /// Makes the driver wait until an expected conditions occurs.
        /// </summary>
        /// <typeparam name="TResult">The type of the result.</typeparam>
        /// <param name="driver">The driver.</param>
        /// <param name="condition">The condition.</param>
        /// <param name="timeout">The timeout.</param>
        /// <returns></returns>
        public static TResult WaitUntil<TResult>(this IWebDriver driver, Func<IWebDriver, TResult> condition, TimeSpan timeout)
        {
            WebDriverWait wait = new WebDriverWait(driver, timeout);
            return wait.Until<TResult>(condition);
        }
    }

    public class ExpectedConditionExtensions
    {
        //This variable will activate or deactivate logging messages.
        //Ideally these should be configured from a config file and not from here.
        private const bool Debug = true;

        public static Func<IWebDriver, bool> ElementAttributeEquals(By locator, string attribute, string expectedValue)
        {
            return (driver) =>
            {
                var actualValue = driver.FindElement(locator).GetAttribute(attribute);

                if (Debug)
                {
                    Console.WriteLine(string.Format("Element: '{0}' has to have in its attribute: '{1}' a value of: '{2}' and it is: '{3}'",
                        locator, attribute, expectedValue, actualValue));
                }

                return actualValue.Equals(expectedValue);
            };
        }

        public static Func<IWebDriver, bool> ElementCssValueEquals(By locator, string cssValue, string expectedValue)
        {
            return (driver) =>
            {
                var actualValue = driver.FindElement(locator).GetCssValue(cssValue);

                if (Debug)
                {
                    Console.WriteLine(string.Format("Element: '{0}' has to have in its CSS: '{1}' a value of: '{2}' and it is: '{3}'",
                        locator, cssValue, expectedValue, actualValue));
                }

                return actualValue.Equals(expectedValue);
            };
        }

        public static Func<IWebDriver, bool> ElementDoesNotExist(By locator)
        {
            return (driver) =>
            {
                try
                {
                    driver.FindElement(locator);
                    return false;
                }
                catch
                {
                    return true;
                }
            };

        }

        public static Func<IWebDriver, bool> ElementIsNotVisible(By locator)
        {
            return (driver) =>
            {
                return !ElementIfVisible(driver.FindElement(locator));
            };
        }

        private static bool ElementIfVisible(IWebElement element)
        {
            if (element.Displayed)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

    }
}