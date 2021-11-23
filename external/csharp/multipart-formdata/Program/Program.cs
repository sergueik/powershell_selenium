using System;
using System.Collections.Specialized;
using System.Net;
using Utils;

namespace Console {

	class Program {

		[STAThread]
		static void Main(string[] args) {
			String url = (args.Length > 1)? args[1]: "http://localhost:8085/basic/upload";
			String uploadfile = (args.Length > 0) ? args[0]: "c:\\temp\\data.txt";
			var cookies = new CookieContainer();
			var querystring = new NameValueCollection();
			querystring["operation"] = "send";
			querystring["param"] = "something";			
			Utils.Utils.UploadFile(uploadfile, url, "file", "text/plain",
				querystring, cookies);

		}
	}
}
