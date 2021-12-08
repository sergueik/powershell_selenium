param(
  [string]$url = 'https://ok.ru/music/newbie'
  # 'https://localhost:8443/welcome'
)


# origin:  http://vcloud-lab.com/entries/powershell/powershell-invoke-webrequest-the-underlying-connection-was-closed-could-not-establish-trust-relationship-for-the-ssl-tls-secure-channel-
# see also: https://til.intrepidintegration.com/powershell/ssl-cert-bypass
# https://social.technet.microsoft.com/Forums/en-US/9982c0f1-962b-4d69-92c1-c48a0bb2b974/how-to-establish-a-ssl-trust-relationship?forum=winserverpowershell
$className = ('{0}_{1}' -f 'ServerCertificateValidationCallback', (Get-Random) )
write-output ('trying the instance method of generated class "{0}"' -f $className)
$certCallback = @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public class ${className} {
	public void Ignore() {
		if (ServicePointManager.ServerCertificateValidationCallback == null) {
			ServicePointManager.ServerCertificateValidationCallback +=
						delegate ( Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors ) { return true; };
		} else {
			Console.Error.WriteLine("The callback is already set");
		}
	}
}
"@
Add-Type $certCallback
$o =  new-object -typename $className
$o.Ignore()

try {
	invoke-webrequest -uri $url -erroraction stop
} catch [exception]{
  Write-Output $_.Exception.Message
}
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
$certCallback = @'
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public class ServerCertificateValidationCallback {
	public static void Ignore() {
		if (ServicePointManager.ServerCertificateValidationCallback == null) {
			ServicePointManager.ServerCertificateValidationCallback +=
						delegate ( Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors ) { return true; };
		}
	}
}
'@
Add-Type $certCallback
	}
write-output ('trying the static method of generated class "{0}"' -f 'ServerCertificateValidationCallback')
[ServerCertificateValidationCallback]::Ignore()

try {
	invoke-webrequest -uri $url -erroraction stop
} catch [exception]{
  Write-Output $_.Exception.Message
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
	invoke-webrequest -uri $url -erroraction stop
} catch [exception]{
  Write-Output $_.Exception.Message
}



add-type @'
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
	public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
'@
write-output ('trying alternative static method of generated class "{0}"' -f '[TrustAllCertsPolicy]::CheckValidationResult')

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

try {
	invoke-webrequest -uri $url -erroraction stop
} catch [exception]{
  Write-Output $_.Exception.Message
}

# Invoke-WebRequest : The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel.
# Invoke-WebRequest : The request was aborted: Could not create SSL/TLS secure channel.
