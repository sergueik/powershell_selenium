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
			text = null;
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
		}
	}
}
