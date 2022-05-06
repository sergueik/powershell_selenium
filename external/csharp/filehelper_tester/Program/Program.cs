using System;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Net;
using System.Linq;
using System.Text;
using System.Threading;
using System.Configuration;
using System.Management.Automation;
using System.Collections.ObjectModel;


using Utils;

namespace Launcher {

	class Program {
		private static string uploadfile = null;
		private static int retries = 10;
		private static int retryInterval = 500;
		private static int holdInterval = 10000;
		private static Boolean debug;
		private static NameValueCollection appSettings;
		
		[STAThread]
		static void Main(string[] args) {

			appSettings = ConfigurationManager.AppSettings;
			
			if (appSettings.AllKeys.Contains("Debug")) {
				debug = Boolean.Parse(appSettings["Debug"]);
			}
			if (appSettings.AllKeys.Contains("RetryInterval")) {
				retryInterval = int.Parse(appSettings["RetryInterval"]);
			}

			if (appSettings.AllKeys.Contains("HoldInterval")) {
				holdInterval = int.Parse(appSettings["HoldInterval"]);
			}

			if (appSettings.AllKeys.Contains("Retries")) {
				retries = int.Parse(appSettings["Retries"]);
			}

			// Alternaively, get the key withut checking if it exists
			var appSettingsReader = new AppSettingsReader();
			uploadfile = (string)(appSettingsReader.GetValue("Datafile", typeof(string)));

			// uploadfile = (args.Length > 0) ? args[0] :
			// (ConfigurationManager.AppSettings.AllKeys.Contains("Datafile")) ? ConfigurationManager.AppSettings["Datafile"] : @"c:\temp\data.txt";

			ParseArgs parseArgs = new ParseArgs(System.Environment.CommandLine);
			if (parseArgs.GetMacro("datafile") != String.Empty) {
				uploadfile = parseArgs.GetMacro("datafile");
			}
			if (parseArgs.GetMacro("retries") != String.Empty) {
				retries = int.Parse(parseArgs.GetMacro("retries"));
			}
			if (parseArgs.GetMacro("retryinterval") != String.Empty) {
				retryInterval = int.Parse(parseArgs.GetMacro("retryinterval"));
			}
			if (parseArgs.GetMacro("holdinterval") != String.Empty) {
				holdInterval = int.Parse(parseArgs.GetMacro("holdinterval"));
			}

			Console.Error.WriteLine("Datafile: " + uploadfile + "\n" +
			"HoldInterval: " + holdInterval + "\n" + "RetryInterval: " + retryInterval + "\n" + "Retries: " + retries);

			var fileHelper = new FileHelper();
			fileHelper.Retries = retries;
			fileHelper.RetryInterval = retryInterval;
			fileHelper.HoldInterval = holdInterval;
			fileHelper.FilePath = uploadfile;
			fileHelper.ReadContents();
			var text = fileHelper.Text;
			if (text != null) {
				Console.Error.WriteLine(String.Format("Read text {0}", text));
				fileHelper.Text = text;
				fileHelper.WriteContents();			
			}
		}
	}
}
