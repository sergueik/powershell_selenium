using System;
using System.IO;

using System.Reflection;
using NSelene;
using OpenQA.Selenium;

namespace NSeleneTests {
	public static class When {
		private static String PrepareBodyHTML(string text) {
			// TODO: convert body quotes
			// like e.g. "<h1 name=\"hello\">Hello Babe!</h1>"
			return "\"" + text.Replace("\r", "").Replace("\n", "") + "\"";
		}
		
		public static void WithBody(string html) {
			Selene.ExecuteScript(
				"document.getElementsByTagName('body')[0].innerHTML = " + PrepareBodyHTML(html) + ";");
			
		}

		public static void WithBody(string html, IWebDriver driver) {
			(driver as IJavaScriptExecutor).ExecuteScript(
				"document.getElementsByTagName('body')[0].innerHTML = " + PrepareBodyHTML(html) + ";");
		}

		// TODO: consider renaming to WithBodyTimedOut
		public static void WithBodyTimedOut(string html, int timeout) {
			Selene.ExecuteScript(@"
                setTimeout(
                    function(){
                        document.getElementsByTagName('body')[0].innerHTML = " + PrepareBodyHTML(html) + "}, " + timeout + ");");
		}

		public static void WithBodyTimedOut(string html, int timeout, IWebDriver driver) {
			(driver as IJavaScriptExecutor).ExecuteScript(@"
                setTimeout(
                    function(){
                        document.getElementsByTagName('body')[0].innerHTML = " + PrepareBodyHTML(html) + "}, " + timeout + ");"
			);
		}

		public static void ExecuteScriptWithTimeout(string js, int timeout) {
			Selene.ExecuteScript(@"
                setTimeout(
                    function(){
                        " + js + @"
                    }, 
                    " + timeout + ");"
			);
		}

		public static void ExecuteScriptWithTimeout(string js, int timeout, IWebDriver driver) {
			(driver as IJavaScriptExecutor).ExecuteScript(@"
                setTimeout(
                    function(){
                        " + js + @"
                    }, 
                    " + timeout + ");"
			);
		}
	}

	public static class Given {
		const String emptyPage = "../../Resources/empty.html";
		/*
			ERR_FILE_NOT_FOUND
			file:///C:/Users/../AppData/Local/Temp/nunit20/ShadowCopyCache/6708_636800834277927465/Tests_27597609/assembly/dl3/Resources/empty.html 
			Your file was not found It may have been moved or deleted.
		*/
		public static void OpenedEmptyPage() {
			Selene.Open(new System.Uri(Path.Combine(Directory.GetCurrentDirectory(), emptyPage)).AbsoluteUri);
			// new Uri(Assembly.GetExecutingAssembly().Location), "../../Resources/empty.html"
		}

		public static void OpenedEmptyPage(IWebDriver driver) {
			driver.Navigate().GoToUrl(new System.Uri(Path.Combine(Directory.GetCurrentDirectory(), emptyPage)).AbsoluteUri
				// new Uri(  new Uri(Assembly.GetExecutingAssembly().Location),  "../../Resources/empty.html" ).AbsoluteUri
			); 
		}

		public static void OpenedPageWithBody(string html) {
			Given.OpenedEmptyPage();
			When.WithBody(html);
		}

		public static void OpenedPageWithBody(string html, IWebDriver driver) {
			Given.OpenedEmptyPage(driver);
			When.WithBody(html, driver);
		}
	}
}

