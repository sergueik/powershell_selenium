using System;
using System.Web;
using System.Collections.Specialized;
using System.Text;
using System.Net;
using System.IO;

namespace Utils {

	public class Utils {
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
			// NOTE: malformed Content-Disposition leads to System.Net.WebException: The remote server returned an error: (400) Bad Request.
			stringBuilder.Append(String.Format("Content-Disposition: form-data; name=\"{0}\"; filename=\"{1}\"", fileFormName, Path.GetFileName(uploadfile)));
			stringBuilder.Append("\r\n");
			stringBuilder.Append("Content-Type: ");
			stringBuilder.Append(contenttype);
			stringBuilder.Append("\r\n");
			stringBuilder.Append("\r\n");			

			string postHeader = stringBuilder.ToString();
			// 
			Console.Error.WriteLine(String.Format("Header {0}" , postHeader));
			byte[] postHeaderBytes = Encoding.UTF8.GetBytes(postHeader);

			byte[] boundaryBytes = Encoding.ASCII.GetBytes("\r\n--" + boundary + "--\r\n");

			var fileStream = new FileStream(uploadfile, FileMode.Open, FileAccess.Read);
			long length = postHeaderBytes.Length + fileStream.Length + boundaryBytes.Length;
			webrequest.ContentLength = length;
			try {
				Stream requestStream = webrequest.GetRequestStream();

				requestStream.Write(postHeaderBytes, 0, postHeaderBytes.Length);

				byte[] buffer = new Byte[checked((uint)Math.Min(4096, (int)fileStream.Length))];
				int bytesRead = 0;			
				while ((bytesRead = fileStream.Read(buffer, 0, buffer.Length)) != 0) {
					text = Encoding.ASCII.GetString(buffer);
					Console.Error.WriteLine(text);
					requestStream.Write(buffer, 0, bytesRead);
				}
				fileStream.Close();
				text = Encoding.ASCII.GetString(boundaryBytes);
				Console.Error.WriteLine(text);
				requestStream.Write(boundaryBytes, 0, boundaryBytes.Length);
				WebResponse response = webrequest.GetResponse();
				Stream stream = response.GetResponseStream();
				var streamReader = new StreamReader(stream);
				var payload = streamReader.ReadToEnd();
				response.Close();
				return payload;
			} catch (WebException e) {
				String message = e.Message;
				if (message.Contains("The remote server returned an error")){
					Console.Error.WriteLine("Failed to post data : " + message);
				} else {
				  Console.Error.WriteLine("Exception (ignored): " + e.ToString());
				}
				return null;
			}
		}
	}
}
