using System;
using System.Diagnostics;

namespace Echevil {
	public class NetworkAdapter {
		internal NetworkAdapter(string name) {
			this.name = name;
		}

		private long dlSpeed, ulSpeed;
		private long dlValue, ulValue;
		private long dlValueOld, ulValueOld;

		internal string name;
		internal PerformanceCounter dlCounter, ulCounter;

		internal void init() {
			// Since dlValueOld and ulValueOld are used in method refresh() to calculate network speed, they must have be initialized.
			this.dlValueOld = this.dlCounter.NextSample().RawValue;
			this.ulValueOld = this.ulCounter.NextSample().RawValue;
		}

		internal void refresh() {
			this.dlValue = this.dlCounter.NextSample().RawValue;
			this.ulValue = this.ulCounter.NextSample().RawValue;
	
			// Calculates download and upload speed.
			this.dlSpeed = this.dlValue - this.dlValueOld;
			this.ulSpeed = this.ulValue - this.ulValueOld;

			this.dlValueOld = this.dlValue;
			this.ulValueOld = this.ulValue;
		}

		public override string ToString() {
			return this.name;
		}

		public string Name {
			get {
				return this.name;
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
