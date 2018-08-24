# use Tomcat shutdown port / verb feature to test socket client in telnet-disabled Windows environment
# https://tomcat.apache.org/tomcat-8.5-doc/config/server.html

<#

  The following does not work

  # https://stackoverflow.com/questions/29759854/how-to-connect-to-tcp-socket-with-powershell-to-send-and-receive-data
  $enc = [System.Text.Encoding]::UTF8
  $string = "SHUTDOWN" 
  $data = $enc.GetBytes($string)
  $server = '127.0.0.1'
  $port = 8005
  $tcp_client = New-Object System.Net.Sockets.TcpClient($server, $port)
  $stream = $tcp_client.GetStream()
  $writer = New-Object System.IO.StreamWriter($stream)
  $writer.AutoFlush = $true

  if ($tcp_client.Connected)
  {
    $writer.WriteLine($command) | Out-Null
    
    $writer.Close()
  $tcp_client.Close()
  }

#>

Add-Type -TypeDefinition @"

// based on: https://docs.microsoft.com/en-us/dotnet/framework/network-programming/synchronous-client-socket-example
using System;
using System.Net;
using System.Net.Sockets;
using System.Text;

public class SynchronousSocketClient
{
		protected string port;
		public string Port { 
			get { return port; }
			set { 
				port = value; 
			}
		}
		protected string message = "This is a test<EOF>";
		public string Message { 
			get { return message; }
			set { 
				message = value; 
			}
		}
		protected string ip_address;
		// NOTE:  can not define property with the same name as the class, like. IPAddress
		// or the compilation error
		// 'string' does not contain a definition for 'Parse' and no extension method 'Parse'
		// accepting a first argument of type 'string' could be found
		public string Address { 
			get { return ip_address; }
			set { 
				ip_address = value; 
			}
		}
		public SynchronousSocketClient() {
  
		}

		public void StartClient()
		{  
			byte[] bytes = new byte[1024];  
      // https://docs.microsoft.com/en-us/dotnet/api/system.net.ipaddress.parse?view=netframework-4.0
			try {
				IPHostEntry ipHostInfo = Dns.GetHostEntry(Dns.GetHostName());  

				IPAddress ipAddress = (String.IsNullOrEmpty(ip_address)) ? ipHostInfo.AddressList[0] : IPAddress.Parse(ip_address);  
      

				int portNumber = 5985;
				Int32.TryParse(port, out portNumber);
				IPEndPoint remoteEP = new IPEndPoint(ipAddress, portNumber);  

				Socket sender = new Socket(ipAddress.AddressFamily, SocketType.Stream, ProtocolType.Tcp);  

				try {  
					sender.Connect(remoteEP);  

					Console.WriteLine("Socket connected to {0}",  
						sender.RemoteEndPoint.ToString());  

					byte[] msg = Encoding.ASCII.GetBytes(message);  

					Console.WriteLine("Sending = {0}", message); 
					int bytesSent = sender.Send(msg);  

					int bytesRec = sender.Receive(bytes);  
					Console.WriteLine("Response = {0}",  
						Encoding.ASCII.GetString(bytes, 0, bytesRec));  

					sender.Shutdown(SocketShutdown.Both);  
					sender.Close();  

				} catch (ArgumentNullException ane) {  
					Console.WriteLine("ArgumentNullException : {0}", ane.ToString());  
				} catch (SocketException se) {  
					Console.WriteLine("SocketException : {0}", se.ToString());  
				} catch (Exception e) {  
					Console.WriteLine("Unexpected exception : {0}", e.ToString());  
				}  

			} catch (Exception e) {  
				Console.WriteLine(e.ToString());  
			}  
		}
}
"@  -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll', 'System.Data.dll', 'System.Net.dll'

$o =  new-object -typeName 'SynchronousSocketClient'
$o.Port = "5985"
$o.Address = "127.0.0.1"
# $o.Message = "SHUTDOWN"
$o.Message = "TEST<EOF>"
# $o.Message = "GET / HTTP/1.1"
# NOTE sending a valid GET  request to WinRM TCP port 5985 is not a good idea (hanging and SocketExeption)
# https://blogs.msdn.microsoft.com/wmi/2009/07/22/new-default-ports-for-ws-management-and-powershell-remoting/

# converting from static method
$o.StartClient()
# [SynchronousSocketClient]::StartClient();

<#
Will respond with 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN""http://www.w3.org/TR/html4/str
ict.dtd">
<HTML><HEAD><TITLE>Bad Request</TITLE>
<META HTTP-EQUIV="Content-Type" Content="text/html; charset=us-ascii"></HEAD>
<BODY><h2>Bad Request - Invalid Verb</h2>
<hr><p>HTTP Error 400. The request verb is invalid.</p>
</BODY></HTML>
#>