using NUnit.Framework;
using System;
using System.Linq;

using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text.RegularExpressions;

using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

// using static NSelene.Selene;
// Need 4.6
// http://gigi.nullneuron.net/gigilabs/data-driven-tests-with-nunit/
using NSelene;

namespace NSeleneTests
{
	[TestFixture]
	public class SWithValidationTests
	{

		// [Ignore("The argument control is missing - ignore the test")]
		[TestCase("a.class > b#id  c:nth-of-type(1)")]
		[TestCase("div.class ~ input#id")]
		[TestCase("body > h1[name='hello'] h2:nth-of-type(1) div")]
		[TestCase("form#formid[name$='form'] input.class[name^='Pass']")]		[ExpectedException(typeof(ArgumentException))]
		public void BadXpathArgumentSearch(String expression) {
			By xpath = With.XPath(expression);
		}

		// [Ignore("The argument control is missing - ignore the test")]
		[TestCase("a[@class='main']/b//c[@class='main']")]
		[TestCase("/body//td/following-sibling::td[1]")]
		[TestCase(@"//div/span[1][@class = ""some""]")]
		[TestCase("/tr[0]/../th")]
		[ExpectedException(typeof(ArgumentException))]
		public void BadCssSelectorArgumentSearch(String expression) {
			By css = With.Css(expression);
		}

	}
}
