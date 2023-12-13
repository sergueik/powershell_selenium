using System.Security.Principal;

using System;
using System.IO;
using System.Linq;

namespace Protractor.TestUtils {

	public class Common {

		private static NgWebDriver ngDriver;
		public static NgWebDriver NgDriver {
			get { return ngDriver; }
			set {
				ngDriver = value;
			}
		}
		
		private static int port;
		public static int Port {
			get { return port; }
			set {
				port = value;
			}
		}

		public static string CreateTempFile(string content){
			FileInfo testFile = new FileInfo("webdriver.tmp");
			if (testFile.Exists) {
				testFile.Delete();
			}
			StreamWriter testFileWriter = testFile.CreateText();
			testFileWriter.WriteLine(content);
			testFileWriter.Close();
			return testFile.FullName;
		}

		// TODO: configm it only works with Chrome:
		// SetUp : System.InvalidOperationException : Access to 'file:///C:/developer/sergueik/powershell_selenium/csharp/protractor-net/Test/bin/Debug/resources/ng_datepicker.htm' from script denied
		public static void GetPageContent(string filename) {
			// NOTE: fixed the invalid path to local resource which is copied to bin/Debug, not creating the "resources" folder within
			driver.Navigate().GoToUrl(new System.Uri(Path.Combine(Directory.GetCurrentDirectory(), filename)).AbsoluteUri);
		}

		public static void GetLocalHostPageContent(string filename) {
			ngDriver.Navigate().GoToUrl(String.Format("http://127.0.0.1:{0}/{1}{2}", port, "resources", filename));
		}

	}
}
