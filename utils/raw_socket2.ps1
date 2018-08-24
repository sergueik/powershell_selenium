# This script opens a socket and sends a simple message,  not really checking the response
# it can be handy in a telnet-disabled Windows environment
# if the set executionpolicy changes is not alowed (or being undone when changed)
# call the script from a batch file
# powershell.exe -executiopolicy remotesigner -file tmpfile.ps1


# use Tomcat shutdown port / verb feature to test socket client
# https://tomcat.apache.org/tomcat-8.5-doc/config/server.html

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

# converted from static method
# [SynchronousSocketClient]::StartClient()

$socket_client =  new-object -typeName 'SynchronousSocketClient'
$socket_client.Address = '127.0.0.1'


$socket_client.Port = '5985'
# $socket_client.Message = "GET / HTTP/1.1"
$socket_client.Message = 'TEST<EOF>'

<#
# NOTE:
# WinRM will proceed malformed requests quickly
# but sending a valid GET  request to WinRM TCP port 5985 is not a good idea:  would hang and throw SocketExeption
# https://blogs.msdn.microsoft.com/wmi/2009/07/22/new-default-ports-for-ws-management-and-powershell-remoting/

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN""http://www.w3.org/TR/html4/str
ict.dtd">
<HTML><HEAD><TITLE>Bad Request</TITLE>
<META HTTP-EQUIV="Content-Type" Content="text/html; charset=us-ascii"></HEAD>
<BODY><h2>Bad Request - Invalid Verb</h2>
<hr><p>HTTP Error 400. The request verb is invalid.</p>
</BODY></HTML>
#>

$socket_client.Address = '127.0.0.1'
$socket_client.Port = '8005'
# replace with tomcat shutdown port and command
# [xml]$server_xml = [xml](get-content 'conf/server.xml')
# $port = $server_xml.Server| where-object { $_.Shutdown -ne ''} | select-object -expandproperty port
# $message = $server_xml.Server| where-object { $_.Shutdown -ne ''} | select-object -expandproperty Shutdown
# and command
$socket_client.Message = 'SHUTDOWN'
$socket_client.StartClient()

# on Catalina end, a java.net.SocketTimeoutException: Read timed out will be logged
# followed by acknowledging the receipt of the message we send