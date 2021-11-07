using System;
using System.Web;
using System.Collections.Specialized;
using System.Text;
using System.Net;
using System.IO;

namespace Utils {

	class UploadFileEx {
		private static String text;
		public static string UploadFile(string uploadfile, string url,
			string fileFormName, string contenttype, NameValueCollection querystring,
			CookieContainer cookies) {
			if (String.IsNullOrEmpty(fileFormName)) {
				fileFormName = "file";
			}

			if (String.IsNullOrEmpty(contenttype)) {
				contenttype = "application/octet-stream";
			}

			string postdata = "?";
			if (querystring != null) {
				foreach (string key in querystring.Keys) {
					postdata += key + "=" + querystring.Get(key) + "&";
				}
			}
			var uri = new Uri(url + postdata);

			string boundary = "----------" + DateTime.Now.Ticks.ToString("x");
			var webrequest = (HttpWebRequest)WebRequest.Create(uri);
			webrequest.CookieContainer = cookies;
			webrequest.ContentType = "multipart/form-data; boundary=" + boundary;
			webrequest.Method = "POST";

		var stringBuilder = new StringBuilder();
			stringBuilder.Append("--");
			stringBuilder.Append(boundary);
			stringBuilder.Append("\r\n");
			stringBuilder.Append("Content-Disposition: form-data; name=\"");
			stringBuilder.Append(fileFormName);
			stringBuilder.Append("\"; filename=\"");
			stringBuilder.Append(Path.GetFileName(uploadfile));
			stringBuilder.Append("\"");
			stringBuilder.Append("\r\n");
			stringBuilder.Append("Content-Type: ");
			stringBuilder.Append(contenttype);
			stringBuilder.Append("\r\n");
			stringBuilder.Append("\r\n");			

			string postHeader = stringBuilder.ToString();
			Console.Error.WriteLine(String.Format("Header {0}" , postHeader));
			byte[] postHeaderBytes = Encoding.UTF8.GetBytes(postHeader);

			byte[] boundaryBytes = Encoding.ASCII.GetBytes("\r\n--" + boundary + "--\r\n");

			var fileStream = new FileStream(uploadfile, FileMode.Open, FileAccess.Read);
			long length = postHeaderBytes.Length + fileStream.Length + boundaryBytes.Length;
			webrequest.ContentLength = length;

			Stream requestStream = webrequest.GetRequestStream();

			requestStream.Write(postHeaderBytes, 0, postHeaderBytes.Length);

			byte[] buffer = new Byte[checked((uint)Math.Min(4096, (int)fileStream.Length))];
			int bytesRead = 0;			
			while ((bytesRead = fileStream.Read(buffer, 0, buffer.Length)) != 0){
				text = Encoding.ASCII.GetString(buffer);
				Console.Error.WriteLine(text);
				requestStream.Write(buffer, 0, bytesRead);
			}
 
			text = Encoding.ASCII.GetString(boundaryBytes);
			Console.Error.WriteLine(text);
			requestStream.Write(boundaryBytes, 0, boundaryBytes.Length);
			WebResponse responce = webrequest.GetResponse();
			Stream stream = responce.GetResponseStream();
			var streamReader = new StreamReader(stream);
			
			return streamReader.ReadToEnd();
		}
		private static String url =  "http://localhost:8085/basic/upload";
		private static String uploadfile = "c:\\temp\\data.txt";

		[STAThread]
		static void Main(string[] args) {
			var cookies = new CookieContainer();
			var querystring = new NameValueCollection();
			
			querystring["operation"] = "send";
			querystring["param"] = "something";			
			UploadFile(uploadfile, url, "file", "text/plain",
				querystring, cookies);

		}
	}
}