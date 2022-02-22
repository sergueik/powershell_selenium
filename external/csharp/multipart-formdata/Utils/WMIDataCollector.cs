using System;
using System.Management;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;

// origin: http://www.java2s.com/Code/CSharp/Development-Class/ComputerdetailsretrievedusingWindowsManagementInstrumentationWMI.htm
// https://stackoverflow.com/questions/21254899/win32-perfformatteddata-counters-processorinformation-class-missing-in-cimv2-nam
// "Win32_PerfFormattedData_Counters_ProcessorInformation" is unavailable on Widows 7 OS
// NOTE: expensive to build (runs for few seconds the first time queried)
namespace Utils {
	public class WMIDataCollector {
		
		private static ManagementObjectSearcher searcher;
		// private static ManagementObject mo;
		private static ManagementObjectCollection mc;
		
		public static void CollectData(Dictionary<string,string> data) {
			
			// UPTIME
			searcher = new ManagementObjectSearcher(new SelectQuery("SELECT LastBootUpTime FROM Win32_OperatingSystem WHERE Primary='true'"));
			var dtBootTime = new DateTime();
			// NOTE: Type and identifier are both required in a foreach statement (CS0230) 
			foreach (ManagementObject  mo in searcher.Get()) {
				dtBootTime = ManagementDateTimeConverter.ToDateTime(mo.Properties["LastBootUpTime"].Value.ToString());
				var dateText = dtBootTime.ToLongDateString();
				var timeText = dtBootTime.ToLongTimeString();
				TimeSpan ts = DateTime.Now - dtBootTime;
				// https://docs.microsoft.com/en-us/dotnet/api/system.timespan?view=netframework-4.5.1
				// totaldays is float
				var daysText = (ts.Days).ToString();
				var hoursText = (ts.Hours).ToString();
				var minutesText = (ts.Minutes).ToString(); 
				data["UPTIME"] = ((daysText != "0") ? daysText + " days" : "") + " " + hoursText + "hours" + " " + minutesText + " min";       
				Console.Error.WriteLine("UPTIME: " + data["UPTIME"]);
			}
			searcher.Dispose();
			
			// QUEUE LENGTH
			searcher = new ManagementObjectSearcher(new SelectQuery("SELECT ProcessorQueueLength from Win32_PerfFormattedData_PerfOS_System"));
			
			// NOTE: Type and identifier are both required in a foreach statement (CS0230) 
			foreach (ManagementObject  mo in searcher.Get()) {
				var measurementDateTime = DateTime.Now;	
				data["DATE"] = measurementDateTime.ToLongDateString();
				data["TIME"] = measurementDateTime.ToLongTimeString();
				// ProcessorQueueLength
				data["QUEUE_LENGTH"] = mo.Properties["ProcessorQueueLength"].Value.ToString();
				Console.Error.WriteLine("QUEUE_LENGTH: " + data["QUEUE_LENGTH"]);
				Console.Error.WriteLine("DATE: " + data["DATE"]);
				Console.Error.WriteLine("TIME: " + data["TIME"]);
			}
			searcher.Dispose();


			// PROCESSOR TIME UTILIZATION (Windows  specific)
			searcher = new ManagementObjectSearcher("SELECT * FROM Win32_PerfFormattedData_Counters_ProcessorInformation");
			try {
				mc = searcher.Get();
				// NOTE: if switching from Powershell to C# inventory, will need to implement
				// "measure-object" and similar cmdlets
				foreach (ManagementObject  mo in mc) {
					Console.Error.WriteLine("PercentIdleTime : " + mo["PercentIdleTime"].ToString() + "\n" +
					"PercentUserTime : " + mo["PercentUserTime"].ToString() + "\n" +
					"PercentInterruptTime: " + mo["PercentInterruptTime"].ToString() + "\n" +
					"PercentProcessorUtility: " + mo["PercentProcessorUtility"].ToString() + "\n" +
					"PercentPrivilegedUtility : " + mo["PercentPrivilegedUtility"].ToString());
				}
			} catch (System.Management.ManagementException e) { 
				Console.Error.WriteLine("Exception (ignored) :" + e.ToString());
			}

			searcher = new ManagementObjectSearcher("SELECT * FROM Win32_OperatingSystem");
			mc = searcher.Get();
			foreach (ManagementObject mo in mc) {
				data["Version"] = mo["version"].ToString();
				data["Computer"] = mo["csname"].ToString();
				Console.WriteLine("Name : " + mo["name"].ToString() + "\n" +
				"Version : " + data["Version"] + "\n" +
				"Manufacturer : " + mo["Manufacturer"].ToString() + "\n" +
				"Computer Name : " + data["Computer"] + "\n" +
				"Windows Directory : " + mo["WindowsDirectory"].ToString());
			}

			searcher = new ManagementObjectSearcher("SELECT * FROM Win32_ComputerSystem");
			mc = searcher.Get();
			foreach (ManagementObject mo in mc) {
				Console.WriteLine("Manufacturer : " + mo["manufacturer"].ToString() + "\n" +
				"Model : " + mo["model"].ToString() + "\n" +
				mo["systemtype"].ToString() + "\n" +
				"Total Physical Memory : " + mo["totalphysicalmemory"].ToString());
			}  

			searcher = new ManagementObjectSearcher("SELECT * FROM Win32_processor");
			mc = searcher.Get();
			foreach (ManagementObject mo in mc) {
				Console.WriteLine(mo["caption"].ToString());
			}                       

			searcher = new ManagementObjectSearcher("SELECT * FROM Win32_bios");
			mc = searcher.Get();
			foreach (ManagementObject mo in mc) {
				Console.WriteLine(mo["version"].ToString());
			}                                   

			searcher = new ManagementObjectSearcher("SELECT * FROM Win32_timezone");
			mc = searcher.Get();
			foreach (ManagementObject mo in mc) {
				Console.WriteLine(mo["caption"].ToString());
			}

		}
	}
}
