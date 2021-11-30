using System;
using System.Diagnostics;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace Utils {

	public class PowershellStarter 	{

		public string ScriptPath { get; set; }
		public string ScriptArguments { get; set; }
		private ProcessStartInfo process;
		private Process PSProcess ;
		private ICollection<string> processOutput ;
		private ICollection<string> processError;
		
		public string ProcessOutput {
			get {
				return String.Join("\r\n", processOutput);
				// return String.Format("{0} lines: {1}", processOutput.Count , String.Join("\r\n", processOutput));
			}
		}

		public string ProcessError {
			get {
				return String.Join("\r\n", processError);
				// return String.Format("{0} lines: {1}", processError.Count ,String.Join("\r\n", processError));
			}
		}

		public PowershellStarter() {
			process = new ProcessStartInfo();
			PSProcess = new System.Diagnostics.Process();	
			processOutput = new Collection<string>();
			processError = new Collection<string>();
		}

		protected virtual void onScriptExited(object sender, EventArgs e){
			// NOTE:  EventArgs type is too generic to be useful here 
		}

		
		public void Start(string ScriptPath, string ScriptParameters, string workingDirectory) {

			process.CreateNoWindow = true;
			process.UseShellExecute = false;
			process.WorkingDirectory = workingDirectory;
			process.RedirectStandardOutput = true;
			process.RedirectStandardError = true;
			process.FileName = @"C:\windows\system32\windowspowershell\v1.0\powershell.exe";
			process.Arguments = "-ExecutionPolicy bypass -File " + ScriptPath + " " + ScriptParameters;

			PSProcess.StartInfo = process;
			PSProcess.EnableRaisingEvents = true;
			PSProcess.Exited += new System.EventHandler(onScriptExited);
		
			PSProcess.OutputDataReceived += (Object sender, DataReceivedEventArgs  EventArgs) => processOutput.Add(EventArgs.Data);
			PSProcess.ErrorDataReceived += (Object sender, DataReceivedEventArgs  EventArgs) => processError.Add( EventArgs.Data);
			// TODO: ignore empty error ?
			bool status = PSProcess.Start();
			if (!status) {
				processError.Add("Failed to start. ExitCode: "  + PSProcess.ExitCode );
			}

			// NOTE: Begin*ReadLine must be set after process has executed.

			PSProcess.BeginOutputReadLine();
			PSProcess.BeginErrorReadLine();
		}

		public void Stop() {
			if (!PSProcess.HasExited) {
				PSProcess.Kill();
			}
		}
	}
}
