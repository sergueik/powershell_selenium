#Copyright (c) 2018 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# This script opens a socket and sends a simple message
# it can be handy in a telnet-disabled Windows environment
# if the set executionpolicy changes is not alowed (or being undone when changed)
# call the script from a batch file
# powershell.exe -executiopolicy remotesigned -file tmpfile.ps1

# based on https://stackoverflow.com/questions/29759854/how-to-connect-to-tcp-socket-with-powershell-to-send-and-receive-data

$enc = [System.Text.Encoding]::UTF8

$server = '127.0.0.1'
$port = 5985
# $message = 'GET / HTTP/1.1'
$message = 'TEST<EOF>'

<#
NOTE:
WinRM https://blogs.msdn.microsoft.com/wmi/2009/07/22/new-default-ports-for-ws-management-and-powershell-remoting/ 
will proceed malformed requests quickly

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN""http://www.w3.org/TR/html4/str
ict.dtd">
<HTML><HEAD><TITLE>Bad Request</TITLE>
<META HTTP-EQUIV="Content-Type" Content="text/html; charset=us-ascii"></HEAD>
<BODY><h2>Bad Request - Invalid Verb</h2>
<hr><p>HTTP Error 400. The request verb is invalid.</p>
</BODY></HTML>

but sending a *valid* GET request to WinRM TCP port 5985 is not a good idea:  
would hang and eventually would throw SocketExeption
#>


$server = '127.0.0.1'
$port = 8005
$message = 'SHUTDOWN'
# use Tomcat shutdown port / verb feature to test socket client https://tomcat.apache.org/tomcat-8.5-doc/config/server.html
# replace with tomcat shutdown port and command from 'server.xml' 
# [xml]$server_xml = [xml](get-content 'conf/server.xml')
# $port = $server_xml.Server| where-object { $_.Shutdown -ne ''} | select-object -expandproperty port
# $message = $server_xml.Server| where-object { $_.Shutdown -ne ''} | select-object -expandproperty Shutdown

$tcp_client = new-object System.Net.Sockets.TcpClient($server, $port)
$stream = $tcp_client.GetStream()
$writer = new-object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

if ($tcp_client.Connected) {
  $writer.WriteLine($message) | out-null
  $writer.Close()
  $tcp_client.Close()
}

# on Catalina end, the receipt of the message we send will be logged
# and a possible shutdown if the message was correct shutdown message
