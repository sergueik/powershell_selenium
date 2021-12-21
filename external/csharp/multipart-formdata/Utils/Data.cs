
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
		public string ToString(){
			String.Format("Name: {0}\nDatacenter: {1}\nPrimary: {2}\nStatus: {3}", Name, Datacenter,Primary, Status)
		}
	}
}
