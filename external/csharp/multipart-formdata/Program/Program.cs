using System;
using System.Collections.Specialized;
using System.IO;
using System.Net;
using Utils;
using System.Web;
using System.Text;

// NOTE:  do not use ".Net reserved" namespaces like "Console"
namespace Launcher {

	class Program
	{
		public  Program() {
		
		}

		[STAThread]
		static void Main(string[] args) {
			String url = (args.Length > 1) ? args[1] : "http://localhost:8085/basic/upload";
			String uploadfile = (args.Length > 0) ? args[0] : "c:\\temp\\data.txt";
			var cookies = new CookieContainer();
			var querystring = new NameValueCollection();
			querystring["operation"] = "send";
			querystring["param"] = "something";			
			Uploader.UploadFile(uploadfile, url, "file", "text/plain",
				querystring, cookies);

			var dataHelper = new DataHelper();
			int retries = 2;
			dataHelper.Retries = retries;
			dataHelper.FilePath = uploadfile;
			dataHelper.ReadContents();
			var text = dataHelper.Text;
			Console.Error.WriteLine(String.Format("Read text {0}", text));
			text = String.Format("{0}\n{1}\n", text, "entry: value");
			dataHelper.Text = text;
			dataHelper.WriteContents();

			WMIDataCollector.CollectData(null);

		}
	}
}
