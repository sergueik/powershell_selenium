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

// NOTE:  do not use ".Net reserved" namespaces like "Console"
namespace Launcher
{

	class Program
	{
		private static string url = null;
		private static string uploadfile = null;
		private static string ScriptPath = null;
		private static string ScriptParameters = null;
		private static string workingDirectory = null;
		private static int runInterval = 10000;
		private static PowershellStarter starter;

		public  Program()
		{
		
		}

		[STAThread]
		static void Main(string[] args)
		{
			url = (args.Length > 1) ? args[1] : 
			(ConfigurationManager.AppSettings.AllKeys.Contains("Url")) ? ConfigurationManager.AppSettings["Url"] : "http://localhost:8085/upload";
			uploadfile = (args.Length > 0) ? args[0] :
			 (ConfigurationManager.AppSettings.AllKeys.Contains("Datafile")) ? ConfigurationManager.AppSettings["Datafile"] : @"c:\temp\data.txt";
			var cookies = new CookieContainer();
			var querystring = new NameValueCollection();
			querystring["operation"] = "send";
			querystring["param"] = "something";			
			Uploader.UploadFile(uploadfile, url, "file", "text/plain",
				querystring, cookies);

			var dataHelper = new DataHelper();
			int retries = 2;
			dataHelper.Retries = retries;
			dataHelper.FilePath = uploadfile;
			dataHelper.ReadContents();
			var text = dataHelper.Text;
			Console.Error.WriteLine(String.Format("Read text {0}", text));
			var helper = new UpdateDataHelper();
			helper.Text = text;
			var newdata = new Dictionary<string,string>();
			WMIDataCollector.CollectData(newdata);
			newdata["Line1"] = "ONE";
			newdata["Line5"] = "five";
			helper.UpdateData(newdata);
			text = helper.Text;
			Console.Error.WriteLine(String.Format("Save text {0}", text));
			dataHelper.Text = text;
			dataHelper.WriteContents();

			ScriptPath = (ConfigurationManager.AppSettings.AllKeys.Contains("ScriptPath")) ? ConfigurationManager.AppSettings["ScriptPath"] : "test.ps1";
			if (ConfigurationManager.AppSettings.AllKeys.Contains("RunInterval"))
				runInterval = Int32.Parse(ConfigurationManager.AppSettings["RunInterval"]);
			
			
			if (ConfigurationManager.AppSettings.AllKeys.Contains("ScriptParameters"))
				ScriptParameters = ConfigurationManager.AppSettings["ScriptParameters"];
			else
				ScriptParameters = @"-outputfile c:\temp\b.log";

			
			// https://stackoverflow.com/questions/3295293/how-to-check-if-an-appsettings-key-exists
			workingDirectory = (ConfigurationManager.AppSettings.AllKeys.Contains("WorkingDirectory")) ? ConfigurationManager.AppSettings["WorkingDirectory"] : AppDomain.CurrentDomain.BaseDirectory;
			
			starter = new PowershellStarter();
			// NOTE
			Console.Error.WriteLine(String.Format("powershell script: {0} parameters: {1} working directory: {2}", ScriptPath, ScriptParameters, workingDirectory));
			starter.Start(workingDirectory /* + "\\"  */ + ScriptPath, ScriptParameters, workingDirectory);
			// TODO: configurable runtime inteval 
			Thread.Sleep(runInterval);
			Console.Error.WriteLine(String.Format("powershell script output: {0} error: {1}", starter.ProcessOutput, starter.ProcessError));
			var Results = new Collection<PSObject>();			
			PowerShell ps = PowerShell.Create();
			try {
				if (Utils.PowershellCommandAdapter.RunPS(ps, 
					   "Get-Service |  Where-Object {$_.canpauseandcontinue -eq \"True\"}", out Results)) {
					Console.Error.WriteLine(String.Format("Poweshell command output:" + String.Join("\r\n", Results)));
				} else {
					Console.Error.WriteLine(String.Format("Poweshell command error: " + String.Join("\r\n", Results)));
				} 
			} catch (System.Management.Automation.RuntimeException e) {
				Console.Error.WriteLine("Exception (ignored): " + e.ToString());
			}                                         
		}
	}
}
