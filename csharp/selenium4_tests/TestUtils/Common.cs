using System.Security.Principal;

using System;
using System.IO;
using System.Linq;
using OpenQA.Selenium;

namespace TestUtils {

	public class Common {

		private static IWebDriver driver;
		public static IWebDriver Driver {
			get { return driver; }
			set {
				driver = value;
			}
		}
		
		private static int port;
		public static int Port {
			get { return port; }
			set {
				port = value;
			}
		}

		public static string CreateTempFile(string content) {
			FileInfo testFile = new FileInfo("webdriver.tmp");
			if (testFile.Exists) {
				testFile.Delete();
			}
			StreamWriter testFileWriter = testFile.CreateText();
			testFileWriter.WriteLine(content);
			testFileWriter.Close();
			return testFile.FullName;
		}

		// only works with Chrome:
		// SetUp : System.InvalidOperationException : Access to 'file:///C:/developer/sergueik/powershell_selenium/csharp/protractor-net/Test/bin/Debug/resources/ng_datepicker.htm' from script denied
		public static void GetPageContent(string filename) {
			driver.Navigate().GoToUrl(new System.Uri(Path.Combine(Path.Combine(Directory.GetCurrentDirectory(), "resources"), filename)).AbsoluteUri);
		}

		public static void GetLocalHostPageContent(string filename) {
			driver.Navigate().GoToUrl(String.Format("http://127.0.0.1:{0}/{1}{2}", port, "resources", filename));
		}

		// origin: https://stackoverflow.com/questions/69503717/how-to-use-random-class-to-shuffle-array-in-c-sharp
		public static string[] shuffle(string[]array) {
			var random = new Random();
			var result = array.OrderBy((item) => random.NextDouble()).ToArray();
			return result;
		}
	}
	
}
