using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Reflection;
using NSelene;
using OpenQA.Selenium;

// TODO: extract common methods to TestUtils namespace
namespace NSeleneTests {
	public static class When {
		
		private static String PrepareBodyHTML(string pageBody) {
			// convert body quotes and chomp line endings
			return "\"" + Regex.Replace(Regex.Replace(pageBody, "\"", "\\\""),"\r?\n", " ") + "\"";
		}
		
		public static void WithBody(string pageBody) {
			Selene.ExecuteScript(
				"document.getElementsByTagName('body')[0].innerHTML = " + PrepareBodyHTML(pageBody) + ";");
			
		}

		public static void WithBody(string pageBody, IWebDriver driver) { (driver as IJavaScriptExecutor).ExecuteScript(
				"document.getElementsByTagName('body')[0].innerHTML = " + PrepareBodyHTML(pageBody) + ";");
		}

		// TODO: consider renaming to WithBodyTimedOut
		public static void WithBodyTimedOut(string pageBody, int timeout) {
			Selene.ExecuteScript(@"
                setTimeout(
                    function(){
                        document.getElementsByTagName('body')[0].innerHTML = " + PrepareBodyHTML(pageBody) + "}, " + timeout + ");");
		}

		public static void WithBodyTimedOut(string pageBody, int timeout, IWebDriver driver) {
			(driver as IJavaScriptExecutor).ExecuteScript(@"
                setTimeout(
                    function(){
                        document.getElementsByTagName('body')[0].innerHTML = " + PrepareBodyHTML(pageBody) + "}, " + timeout + ");"
			);
		}

		public static void ExecuteScriptWithTimeout(string script, int timeout) {
			// NOTE: script may contain newlines
			Selene.ExecuteScript(@"
	       		  setTimeout(
	                    function(){ " + script + @" }, " + timeout + ");" );
		}

		public static void ExecuteScriptWithTimeout(string script, int timeout, IWebDriver driver) {
			(driver as IJavaScriptExecutor).ExecuteScript(@"
                setTimeout(
                    function(){
                        " + script + @"
                    }, 
                    " + timeout + ");"
			);
		}
	}

	public static class Given {

		const String emptyPage = "../../Resources/empty.html";

		// Loading the empty page with RunFromAssemblyLocation set to "true" does not seem to work:
		// ERR_FILE_NOT_FOUND
		// file:///C:/Users/../AppData/Local/Temp/nunit20/ShadowCopyCache/6708_636800834277927465/Tests_27597609/assembly/dl3/Resources/empty.html 
		// Your file was not found It may have been moved or deleted.

		// Therefore the class initialzed with the default value of "false"

		private static Boolean runFromAssemblyLocation = false;
		
		public static Boolean RunFromAssemblyLocation {                                                                               
			get {                                                                           
				return runFromAssemblyLocation;                                                      
			}                                                                           
			set {                                                                           
				runFromAssemblyLocation = value;                                                     
			}                                                                           
		}


		public static void OpenedEmptyPage() {
			String uri = new Uri(Path.Combine(
				runFromAssemblyLocation ? Assembly.GetExecutingAssembly().Location : Directory.GetCurrentDirectory(), emptyPage)).AbsoluteUri;
			Selene.Open(uri);
		}

		public static void OpenedEmptyPage(IWebDriver driver) {
			driver.Navigate().GoToUrl(new Uri(Path.Combine(Directory.GetCurrentDirectory(), emptyPage)).AbsoluteUri
				// new Uri(  new Uri(Assembly.GetExecutingAssembly().Location),  "../../Resources/empty.html" ).AbsoluteUri
			); 
		}

		public static void OpenedPageWithBody(string pageBody) {
			Given.OpenedEmptyPage();
			When.WithBody(pageBody);
		}

		public static void OpenedPageWithBody(string pageBody, IWebDriver driver) {
			Given.OpenedEmptyPage(driver);
			When.WithBody(pageBody, driver);
		}
	}
}

