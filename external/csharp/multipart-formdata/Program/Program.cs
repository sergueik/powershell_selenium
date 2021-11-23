using System;
using System.Collections.Specialized;
using System.Net;

namespace Utils {

	class Program {
		private static String url =  "http://localhost:8085/basic/upload";
		private static String uploadfile = "c:\\temp\\data.txt";

		[STAThread]
		static void Main(string[] args) {
			var cookies = new CookieContainer();
			var querystring = new NameValueCollection();
			if (args.Length > 0) { 
				uploadfile = args[0];
			}
			if (args.Length > 1) { 
				url = args[1];
			}
			querystring["operation"] = "send";
			querystring["param"] = "something";			
			Utils.UploadFile(uploadfile, url, "file", "text/plain",
				querystring, cookies);

		}
	}
}
