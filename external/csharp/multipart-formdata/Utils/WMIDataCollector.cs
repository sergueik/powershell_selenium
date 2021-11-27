using System;
using System.Management;

// origin: http://www.java2s.com/Code/CSharp/Development-Class/ComputerdetailsretrievedusingWindowsManagementInstrumentationWMI.htm
// https://stackoverflow.com/questions/21254899/win32-perfformatteddata-counters-processorinformation-class-missing-in-cimv2-nam
// "Win32_PerfFormattedData_Counters_ProcessorInformation" is unavailable on Widows 7 OS
// NOTE: expensive to build (runs for few seconds the first time queried)
namespace Utils {
	public class WMIDataCollector {
		public static void CollectData(string[] args) {
			var query1 = new ManagementObjectSearcher("SELECT * FROM Win32_PerfFormattedData_Counters_ProcessorInformation");
			try {
				var queryCollection1 = query1.Get();
				// is switching from Powershell to C# inventory, will need to implement
				// "measure-object" and similar cmdlets
				foreach (ManagementObject mo in queryCollection1) {
					Console.WriteLine("PercentIdleTime : " + mo["PercentIdleTime"].ToString());
					Console.WriteLine("PercentUserTime : " + mo["PercentUserTime"].ToString());
					Console.WriteLine("PercentInterruptTime: " + mo["PercentInterruptTime"].ToString());
					Console.WriteLine("PercentProcessorUtility: " + mo["PercentProcessorUtility"].ToString());
					Console.WriteLine("PercentPrivilegedUtility : " + mo["PercentPrivilegedUtility"].ToString());
				}
			} catch (System.Management.ManagementException e) { 
				Console.Error.WriteLine("Exception (ignored) :" + e.ToString());
			}

			/*
			                     var query1 = new ManagementObjectSearcher("SELECT * FROM Win32_OperatingSystem");
                        var queryCollection1 = query1.Get();
                        foreach (ManagementObject mo in queryCollection1) {
                                Console.WriteLine("Name : " + mo["name"].ToString());
                                Console.WriteLine("Version : " + mo["version"].ToString());
                                Console.WriteLine("Manufacturer : " + mo["Manufacturer"].ToString());
                                Console.WriteLine("Computer Name : " + mo["csname"].ToString());
                                Console.WriteLine("Windows Directory : " + mo["WindowsDirectory"].ToString());
                        }

			query1 = new ManagementObjectSearcher("SELECT * FROM Win32_ComputerSystem");
			queryCollection1 = query1.Get();
			foreach (ManagementObject mo in queryCollection1) {
				Console.WriteLine("Manufacturer : " + mo["manufacturer"].ToString());
				Console.WriteLine("Model : " + mo["model"].ToString());
				Console.WriteLine(mo["systemtype"].ToString());
				Console.WriteLine("Total Physical Memory : " + mo["totalphysicalmemory"].ToString());
			}  

			query1 = new ManagementObjectSearcher("SELECT * FROM Win32_processor");
			queryCollection1 = query1.Get();
			foreach (ManagementObject mo in queryCollection1) {
				Console.WriteLine(mo["caption"].ToString());
			}                       

			query1 = new ManagementObjectSearcher("SELECT * FROM Win32_bios");
			queryCollection1 = query1.Get();
			foreach (ManagementObject mo in queryCollection1) {
				Console.WriteLine(mo["version"].ToString());
			}                                   

			query1 = new ManagementObjectSearcher("SELECT * FROM Win32_timezone");
			queryCollection1 = query1.Get();
			foreach (ManagementObject mo in queryCollection1) {
				Console.WriteLine(mo["caption"].ToString());
			}
*/
		}
	}
}
