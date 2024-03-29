using System;
using System.Web;
using System.Collections.Specialized;
using System.Text;
using System.Net;
using System.IO;

namespace Utils {

	public class SvrInfoHelper {
		private String url;
		public String Url {
			get {
				return url;
			}
			set {
				url = value;
			}
		}
		private String text;
		public string Text { 
			get {
				return text;
			}
		}
		public SvrInfoHelper(string url) {
			this.Url = url;
		}
		public void getSvrInfo() {
			Console.WriteLine("SVRINFO:");
			text = null;
			ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Ssl3; 
			ServerCertificateValidationCallback.Ignore();
			WebRequest request = WebRequest.Create(url);
			request.Proxy = null;
			request.Credentials = CredentialCache.DefaultCredentials;
/*
 System.Net.ServicePointManager.ServerCertificateValidationCallback +=
    delegate(object sender, System.Security.Cryptography.X509Certificates.X509Certificate certificate, System.Security.Cryptography.X509Certificates.X509Chain chain, System.Net.Security.SslPolicyErrors sslPolicyErrors){
            return true;
        };
 */
			var response = (HttpWebResponse)request.GetResponse();
			Stream dataStream = response.GetResponseStream();
			var reader = new StreamReader(dataStream);
			text = reader.ReadToEnd();
			
			String[] lines = text.Split('\n');
			foreach (var line in lines) {
				String[] tokens = line.Split(',');
				var data = new Data();
				data.Name = tokens[0];
				data.Datacenter = tokens[1];
				data.Primary = Boolean.Parse(tokens[2]);
				data.Status = Boolean.Parse(tokens[3]);
				Console.WriteLine(data.ToString());
			}
		}
	}
}
