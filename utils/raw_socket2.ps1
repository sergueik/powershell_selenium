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
	protected string ip_address;
	public string IPAddress { 
		get { return ip_address; }
		set { 
			ip_address = value; 
		}
	}
	public static void StartClient()
	{  
		// Data buffer for incoming data.  
		byte[] bytes = new byte[1024];  

		// Connect to a remote device.  
		try {  
			// Establish the remote endpoint for the socket.  
			// This example uses port 11000 on the local computer.  
			IPHostEntry ipHostInfo = Dns.GetHostEntry(Dns.GetHostName());  
			IPAddress ipAddress = ipHostInfo.AddressList[0];  
			IPEndPoint remoteEP = new IPEndPoint(ipAddress, 5985);  

			// Create a TCP/IP  socket.  
			Socket sender = new Socket(ipAddress.AddressFamily,   
				                         SocketType.Stream, ProtocolType.Tcp);  

			// Connect the socket to the remote endpoint. Catch any errors.  
			try {  
				sender.Connect(remoteEP);  

				Console.WriteLine("Socket connected to {0}",  
					sender.RemoteEndPoint.ToString());  

				// Encode the data string into a byte array.  
				byte[] msg = Encoding.ASCII.GetBytes("This is a test<EOF>");  

				// Send the data through the socket.  
				int bytesSent = sender.Send(msg);  

				// Receive the response from the remote device.  
				int bytesRec = sender.Receive(bytes);  
				Console.WriteLine("Echoed test = {0}",  
					Encoding.ASCII.GetString(bytes, 0, bytesRec));  

				// Release the socket.  
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

# converting from static method
# $o.StartClient();
[SynchronousSocketClient]::StartClient();

<#
Will respond with 
<HTML><HEAD><TITLE>Bad Request</TITLE>
<META HTTP-EQUIV="Content-Type" Content="text/html; charset=us-ascii"></HEAD>
<BODY><h2>Bad Request</h2>
<hr><p>HTTP Error 400. The request is badly formed.</p>
</BODY></HTML>
#>