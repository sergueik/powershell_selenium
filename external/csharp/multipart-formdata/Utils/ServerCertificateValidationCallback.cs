using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
namespace Utils {
	public class ServerCertificateValidationCallback {
		public static void Ignore() {
			if (ServicePointManager.ServerCertificateValidationCallback == null) {
				ServicePointManager.ServerCertificateValidationCallback +=
						delegate ( Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors) {
					return true;
				};
			}
		}
	}
}