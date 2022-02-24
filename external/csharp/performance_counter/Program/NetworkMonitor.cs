using System;
using System.Timers;
using System.Collections;
using System.Diagnostics;

namespace Echevil {
	public class NetworkMonitor {
		private Timer timer;
		// The timer event executes every second to refresh the values in adapters.
		private ArrayList adapters;
		// The list of adapters on the computer.
		private ArrayList monitoredAdapters;
		// The list of currently monitored adapters.

		public NetworkMonitor() {
			this.adapters = new ArrayList();
			this.monitoredAdapters = new ArrayList();
			EnumerateNetworkAdapters();
	
			timer = new Timer(1000);
			timer.Elapsed += new ElapsedEventHandler(timer_Elapsed);
		}

		private void EnumerateNetworkAdapters() {
			
			var performanceCounterCategories = PerformanceCounterCategory.GetCategories();

			foreach (PerformanceCounterCategory performanceCounterCategory in performanceCounterCategories) {
				if (performanceCounterCategory.CategoryName.IndexOf("System") != -1) {
					var name = performanceCounterCategory.CategoryName;
					Console.WriteLine(name);
				}
			}
			

			// var category = new PerformanceCounterCategory("System");

			var category = new PerformanceCounterCategory("Network Interface");
			foreach (string name in category.GetInstanceNames()) {
				// This one exists on every computer.
				if (name == "MS TCP Loopback interface")
					continue;
				// Create an instance of NetworkAdapter class, and create performance counters for it.
				var adapter = new NetworkAdapter(name);
				adapter.dlCounter = new PerformanceCounter("Network Interface", "Bytes Received/sec", name);
				adapter.ulCounter = new PerformanceCounter("Network Interface", "Bytes Sent/sec", name);
				// System.InvalidOperationException: Category does not exist.
				// at System.Diagnostics.PerformanceCounterLib.CounterExists(String machine, String category, String counter)
				// at System.Diagnostics.PerformanceCounterCategory.CounterExists(String counterName, String categoryName, String machineName)
				// at System.Diagnostics.PerformanceCounterCategory.CounterExists(String counterName, String categoryName)
   			
				try {
   					
					PerformanceCounter myCounter = new PerformanceCounter();
					myCounter.CategoryName = "System";
					myCounter.CounterName = "Processor Queue Length";
					myCounter.InstanceName = null;
					// throwing exception
					// long raw3 = myCounter.RawValue;
					adapter.resultCounter = myCounter;
					// Determines whether a specified counter is registered to a particular categor
					// Processor Queue Length is not collected by default on any windows servers. It is included as part of APPInsight for AD and the component is using a Performance Counter Monitor as referenced in the details of the component
					// https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-2000-server/cc938643(v=technet.10)?redirectedfrom=MSDN
					// http://toncigrgin.blogspot.com/2015/11/windows-perf-counters-blog4.html
					// if (PerformanceCounterCategory.CounterExists( "System", "Processor Queue Length", ".")) {
					// adapter.resultCounter = new PerformanceCounter("System", "Processor Queue Length");
					// }
				} catch (System.InvalidOperationException e) {
					// Category does not exist.
					Console.Error.WriteLine("Exception: " + e.ToString());
				}
				this.adapters.Add(adapter);

			}	
		}

		private void timer_Elapsed(object sender, ElapsedEventArgs e) {
			foreach (NetworkAdapter adapter in this.monitoredAdapters)
				adapter.refresh();
		}

		public NetworkAdapter[] Adapters {
			get {
				return (NetworkAdapter[])this.adapters.ToArray(typeof(NetworkAdapter));
			}
		}

		public void StartMonitoring() {
			if (this.adapters.Count > 0) {
				foreach (NetworkAdapter adapter in this.adapters)
					if (!this.monitoredAdapters.Contains(adapter)) {
						this.monitoredAdapters.Add(adapter);
						adapter.init();
					}
	
				timer.Enabled = true;
			}
		}

		public void StartMonitoring(NetworkAdapter adapter) {
			if (!this.monitoredAdapters.Contains(adapter)) {
				this.monitoredAdapters.Add(adapter);
				adapter.init();
			}
			timer.Enabled =	true;
		}

		public void StopMonitoring() {
			this.monitoredAdapters.Clear();
			timer.Enabled =	false;
		}

		public void StopMonitoring(NetworkAdapter adapter) {
			if (this.monitoredAdapters.Contains(adapter))
				this.monitoredAdapters.Remove(adapter);	
			if (this.monitoredAdapters.Count == 0)
				timer.Enabled =	false;
		}
	}
}
