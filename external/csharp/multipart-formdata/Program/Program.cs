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
		private static string infoUrl = null;
		private static string uploadUrl = null;
		private static string uploadfile = null;
		private static string ScriptPath = null;
		private static string ScriptParameters = null;
		private static string workingDirectory = null;
		private static int runInterval = 10000;
		private static ProcessStarter processStarter;

		[STAThread]
		static void Main(string[] args) {
			// TODO: AppSettings is not working ?
			uploadfile = (args.Length > 0) ? args[0] :
			 (ConfigurationManager.AppSettings.AllKeys.Contains("Datafile")) ? ConfigurationManager.AppSettings["Datafile"] : @"c:\temp\data.txt";
			uploadUrl = (args.Length > 1) ? args[1] : 
			(ConfigurationManager.AppSettings.AllKeys.Contains("UploadUrl")) ? ConfigurationManager.AppSettings["UploadUrl"] : "https://127.0.0.1:8443/upload";
			infoUrl = (args.Length > 2) ? args[2] : 
				// NOTE: localhost is resolved in IPV6 fashion:
				// System.Net.Sockets.SocketException: No connection could be made because the target machine actively refused it [::1]:8443
				// [::1]:8443
			(ConfigurationManager.AppSettings.AllKeys.Contains("InfoUrl")) ? ConfigurationManager.AppSettings["InfoUrl"] : "https://127.0.0.1:8443/svrinfo";
			var svrInfoHelper = new SvrInfoHelper(infoUrl);
			// TODO: try catch
			// when basic-https spring-boot application is not run fails
			try {
				svrInfoHelper.getSvrInfo();
				Console.Error.WriteLine(String.Format("Received:\n{0}", svrInfoHelper.Text));
			} catch (Exception e) {
				Console.Error.WriteLine("Exception (ignored): " + e.ToString());
			}
			var cookies = new CookieContainer();
			var querystring = new NameValueCollection();
			querystring["operation"] = "send";
			querystring["param"] = "something";			
			Uploader.UploadFile(uploadfile, uploadUrl, "file", "text/plain",
				querystring, cookies);

			var fileHelper = new FileHelper();
			int retries = 2;
			fileHelper.Retries = retries;
			fileHelper.FilePath = uploadfile;
			fileHelper.ReadContents();
			var text = fileHelper.Text;
			Console.Error.WriteLine(String.Format("Read text {0}", text));
			var updateDataHelper = new UpdateDataHelper();
			updateDataHelper.Text = text;
			var newdata = new Dictionary<string,string>();
			WMIDataCollector.CollectData(newdata);
			newdata["Line1"] = "ONE";
			newdata["Line5"] = "five";
			updateDataHelper.UpdateData(newdata);
			text = updateDataHelper.Text;
			Console.Error.WriteLine(String.Format("Save text {0}", text));
			fileHelper.Text = text;
			fileHelper.WriteContents();

			ScriptPath = (ConfigurationManager.AppSettings.AllKeys.Contains("ScriptPath")) ? ConfigurationManager.AppSettings["ScriptPath"] : "test.ps1";
			if (ConfigurationManager.AppSettings.AllKeys.Contains("RunInterval"))
				runInterval = Int32.Parse(ConfigurationManager.AppSettings["RunInterval"]);
			
			
			if (ConfigurationManager.AppSettings.AllKeys.Contains("ScriptParameters"))
				ScriptParameters = ConfigurationManager.AppSettings["ScriptParameters"];
			else
				ScriptParameters = @"-outputfile c:\temp\b.log";

			
			// https://stackoverflow.com/questions/3295293/how-to-check-if-an-appsettings-key-exists
			workingDirectory = (ConfigurationManager.AppSettings.AllKeys.Contains("WorkingDirectory")) ? ConfigurationManager.AppSettings["WorkingDirectory"] : AppDomain.CurrentDomain.BaseDirectory;
			
			processStarter = new ProcessStarter();
			// NOTE
			Console.Error.WriteLine(String.Format("powershell script: {0} parameters: {1} working directory: {2}", ScriptPath, ScriptParameters, workingDirectory));
						
			processStarter.Start(workingDirectory /* + "\\"  */ + ScriptPath, ScriptParameters, workingDirectory);
 
			Thread.Sleep(runInterval);
			
			Console.Error.WriteLine(String.Format(
				"powershell script output: {0}", processStarter.ProcessOutput + ((processStarter.ProcessError.Length > 0) ? " error: " + processStarter.ProcessError : "")));
			
			var Results = new Collection<PSObject>();			
			PowerShell ps = PowerShell.Create();
			// var script = "Get-ChildItem -path $env:TEMP | Measure-Object -Property length -Minimum -Maximum -Sum -Average";
			var script = "get-computerinfo -erroraction stop";
			try {
				if (Utils.PowershellCommandAdapter.RunPS(ps, script, out Results)) {
					Console.Error.WriteLine("Powershell command output:");
					for (var cnt = 0; cnt != Results.Count; cnt++) {
						var row = Results[cnt];
						var columnEnumerator = row.Properties.GetEnumerator();
						columnEnumerator.Reset();
						while (columnEnumerator.MoveNext()) {
							var column = columnEnumerator.Current;
							Console.Error.WriteLine(String.Format("{0}: {1}", column.Name, column.Value));
						}
					}
				} else {
					Console.Error.WriteLine("Powershell command error: " +  Utils.PowershellCommandAdapter.LastErrors.First());
				} 
			} catch (RuntimeException e) {
				Console.Error.WriteLine("Exception (ignored): " + e.ToString());
			} 
			
		}
	}
}
