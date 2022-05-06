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

		[STAThread]
		static void Main(string[] args) {

			// Alternaively, get the key withut checking if it exists
			var appSettingsReader = new AppSettingsReader();
			uploadfile = (string)(appSettingsReader.GetValue("Datafile", typeof(string)));
			Console.Error.WriteLine("Datafile: " + uploadfile);

			uploadfile = (args.Length > 0) ? args[0] :
			 (ConfigurationManager.AppSettings.AllKeys.Contains("Datafile")) ? ConfigurationManager.AppSettings["Datafile"] : @"c:\temp\data.txt";
			Console.Error.WriteLine("Datafile: " + uploadfile);

			var fileHelper = new FileHelper();
			int retries = 10;
			fileHelper.Retries = retries;
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
