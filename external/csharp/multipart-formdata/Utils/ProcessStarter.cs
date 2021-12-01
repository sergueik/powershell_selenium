using System;
using System.Diagnostics;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace Utils {

	public class ProcessStarter 	{

		public string ScriptPath { get; set; }
		public string ScriptArguments { get; set; }
		private ProcessStartInfo processStartInfo;
		private Process process ;
		private ICollection<string> processStartInfoOutput ;
		private ICollection<string> processStartInfoError;
		
		public string ProcessOutput {
			get {
				return String.Join("\r\n", processStartInfoOutput);
				// return String.Format("{0} lines: {1}", processStartInfoOutput.Count , String.Join("\r\n", processStartInfoOutput));
			}
		}

		public string ProcessError {
			get {
				return String.Join("\r\n", processStartInfoError);
				// return String.Format("{0} lines: {1}", processStartInfoError.Count ,String.Join("\r\n", processStartInfoError));
			}
		}

		public ProcessStarter() {
			processStartInfo = new ProcessStartInfo();
			process = new System.Diagnostics.Process();	
			processStartInfoOutput = new Collection<string>();
			processStartInfoError = new Collection<string>();
		}

		protected virtual void onScriptExited(object sender, EventArgs e){
			// NOTE:  EventArgs type is too generic to be useful here 
		}

		
		public void Start(string ScriptPath, string ScriptParameters, string workingDirectory) {

			processStartInfo.CreateNoWindow = true;
			processStartInfo.UseShellExecute = false;
			processStartInfo.WorkingDirectory = workingDirectory;
			processStartInfo.RedirectStandardOutput = true;
			processStartInfo.RedirectStandardError = true;
			processStartInfo.FileName = @"C:\windows\system32\windowspowershell\v1.0\powershell.exe";
			processStartInfo.Arguments = "-ExecutionPolicy bypass -File " + ScriptPath + " " + ScriptParameters;

			process.StartInfo = processStartInfo;
			process.EnableRaisingEvents = true;
			process.Exited += new System.EventHandler(onScriptExited);
		
			process.OutputDataReceived += (Object sender, DataReceivedEventArgs  EventArgs) => processStartInfoOutput.Add(EventArgs.Data);
			process.ErrorDataReceived += (Object sender, DataReceivedEventArgs EventArgs) => collectError(EventArgs);		
			// TODO: ignore empty error ?
			bool status = process.Start();
			if (!status) {
				processStartInfoError.Add("Failed to start. ExitCode: "  + process.ExitCode );
			}

			// NOTE: Begin*ReadLine must be set after processStartInfo has executed.

			process.BeginOutputReadLine();
			process.BeginErrorReadLine();
		}

		
		private void collectError(DataReceivedEventArgs eventArgs) {
			if (!String.IsNullOrEmpty(eventArgs.Data))
				processStartInfoError.Add(eventArgs.Data); 
		}

		public void Stop() {
			if (!process.HasExited) {
				process.Kill();
			}
		}
	}
}
