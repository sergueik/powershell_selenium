using System;
using System.Diagnostics;

namespace Echevil {
	public class NetworkAdapter {
		// new field
		private long result;
		
		private long dlSpeed, ulSpeed;
		private long dlValue, ulValue;
		private long dlValueOld, ulValueOld;

		internal string name;
		internal PerformanceCounter dlCounter, ulCounter;
		internal PerformanceCounter resultCounter;

		internal NetworkAdapter(string name) {
			this.name = name;
		}
		
		internal void init() {
			// Since dlValueOld and ulValueOld are used in method refresh() to calculate network speed, they must have be initialized.
			dlValueOld = dlCounter.NextSample().RawValue;
			ulValueOld = ulCounter.NextSample().RawValue;
			if (resultCounter != null) {
				try {
					result = resultCounter.NextSample().RawValue;
				} catch (System.InvalidOperationException e) {
					Console.Error.WriteLine("Exception with counter {0}: {1}" ,resultCounter.CounterName, e.ToString());
					// Category does not exist.
				}
			}
		}

		internal void refresh() {
			dlValue = dlCounter.NextSample().RawValue;
			ulValue = ulCounter.NextSample().RawValue;
			if (resultCounter != null) {
				result = resultCounter.NextSample().RawValue;
			}
			// Calculates download and upload speed.
			dlSpeed = dlValue - dlValueOld;
			ulSpeed = ulValue - ulValueOld;

			dlValueOld = dlValue;
			ulValueOld = ulValue;
		}

		public override string ToString() {
			return name;
		}

		public string Name {
			get {
				return name;
			}
		}
		public long DownloadSpeed {
			get {
				return this.dlSpeed;
			}
		}
		public long UploadSpeed {
			get {
				return this.ulSpeed;
			}
		}
		public double DownloadSpeedKbps {
			get {
				return this.dlSpeed / 1024.0;
			}
		}

		public double UploadSpeedKbps {
			get {
				return this.ulSpeed / 1024.0;
			}
		}
	}
}
