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
			PerformanceCounterCategory category = new PerformanceCounterCategory("Network Interface");

			foreach (string name in category.GetInstanceNames()) {
				// This one exists on every computer.
				if (name == "MS TCP Loopback interface")
					continue;
				// Create an instance of NetworkAdapter class, and create performance counters for it.
				NetworkAdapter adapter = new NetworkAdapter(name);
				adapter.dlCounter = new PerformanceCounter("Network Interface", "Bytes Received/sec", name);
				adapter.ulCounter = new PerformanceCounter("Network Interface", "Bytes Sent/sec", name);
				this.adapters.Add(adapter);			// Add it to ArrayList adapter
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
