
using System;

namespace Utils {
	public class Data {
		
		public string Datacenter { get; set; }
		public string Name { get; set; }
		public bool Primary { get; set; }
		public bool Status { get; set; }
		public Data() { }
		public Data(string name, string datacenter, bool primary, bool status) {
			this.Name = name;
			this.Datacenter = datacenter;
			this.Primary = primary;
			this.Status = status;
		}
		public override string ToString() {
			return String.Format("Name: {0}" + "\n" + "Datacenter: {1}" + "\n" + "Primary: {2}" + "\n" + "Status: {3}", Name, Datacenter, Primary, Status);
		}
	}
}
