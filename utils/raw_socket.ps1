# This script opens a socket and sends a simple message
# it can be handy in a telnet-disabled Windows environment
# if the set executionpolicy changes is not alowed (or being undone when changed)
# call the script from a batch file
# powershell.exe -executiopolicy remotesigned -file tmpfile.ps1


# based on https://stackoverflow.com/questions/29759854/how-to-connect-to-tcp-socket-with-powershell-to-send-and-receive-data

$enc = [System.Text.Encoding]::UTF8

$server = '127.0.0.1'
$port = 8005
$command = 'SHUTDOWN'
# use Tomcat shutdown port / verb feature to test socket client
# https://tomcat.apache.org/tomcat-8.5-doc/config/server.html

$tcp_client = new-object System.Net.Sockets.TcpClient($server, $port)
$stream = $tcp_client.GetStream()
$writer = new-object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

if ($tcp_client.Connected)
{
  # $bytes = $enc.GetBytes($command)
  # $writer.WriteLine($bytes) | out-null
  # Catalina will acknowledge receipt of a `System.Byte[]` - the [String] argument is required with streamSWriter

  $writer.WriteLine($command) | Out-Null
  $writer.Close()
  $tcp_client.Close()
}

# on Catalina end, the receipt of the message we send will be logged