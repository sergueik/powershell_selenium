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

		// TODO: confirm it only works with Chrome:
		public static void GetPageContent(string filename) {
			// NOTE: fixed the invalid path to local resource which is copied to bin/Debug, not creating the "resources" folder within
			driver.Navigate().GoToUrl(new System.Uri(Path.Combine(Directory.GetCurrentDirectory(), filename)).AbsoluteUri);
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
