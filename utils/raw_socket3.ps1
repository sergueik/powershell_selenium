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

# This script opens a socket and sends a provided message, receives and prints to console the response
# it can be handy in a telnet-disabled Windows environment
# if the set executionpolicy changes is not alowed (or being undone when changed)
# call the script from a batch file
# powershell.exe -executiopolicy remotesigned -file tmpfile.ps1

# use Tomcat shutdown port / verb feature to test socket client
# https://tomcat.apache.org/tomcat-8.5-doc/config/server.html

# converted from: https://docs.microsoft.com/en-us/dotnet/framework/network-programming/synchronous-client-socket-example

$loopback_address = '127.0.0.1'
# replace with tomcat shutdown port and command from 'server.xml' 
# [xml]$server_xml = [xml](get-content 'conf/server.xml')
# $port = $server_xml.Server| where-object { $_.Shutdown -ne ''} | select-object -expandproperty port
# $message = $server_xml.Server| where-object { $_.Shutdown -ne ''} | select-object -expandproperty Shutdown
# Tomcat shutdown port
$port = 8005
$message = 'SHUTDOWN'
# on Catalina end, a java.net.SocketTimeoutException: Read timed out will be logged
# followed by acknowledgment of the receipt of the message sent by the script
# and a possible shutdown if the message was correct shutdown message

# WinRM port
[int] $port = 5985
# WinRM https://blogs.msdn.microsoft.com/wmi/2009/07/22/new-default-ports-for-ws-management-and-powershell-remoting/
# will proceed malformed requests like
# dummy message 
$mesage = 'TEST<EOF>'
# - WinRM will respond with the HTTP Error 400. The request verb is invalid error quickly 
# but sending a *valid* GET request to WinRM TCP port 5985 is not a good idea:  
# would hang and eventually would throw SocketExeption

# NOTE: this will not get loopback address
[System.Net.IPHostEntry]$ipHostInfo = [System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName())
[System.Net.IPAddress[]]$ipAddressList = $ipHostInfo.AddressList
# e.g. {172.17.8.1, 192.168.33.1, 192.168.0.25, ::1}
[System.Net.IPAddress]$ipAddress = $ipaddressList | where-object { $_.AddressFamily -ne 'InterNetworkV6' } | select-object -first 1

$ipAddress = [System.Net.IPAddress]::Parse($loopback_address)
[System.Net.IPEndPoint] $remoteEP = new-object System.Net.IPEndPoint($ipAddress, $port)
[System.Net.Sockets.Socket]$sender = new-object System.Net.Sockets.Socket($ipAddress.AddressFamily, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
$sender.Connect($remoteEP)
write-debug $sender.RemoteEndPoint.ToString()
# 172.17.8.1:5985
$enc = [System.Text.Encoding]::UTF8
[byte[]]$bytes = $enc.GetBytes($message)
[int]$bytes_sent = $sender.Send($bytes)
$bytes = new-object Byte[] 1024
[int]$bytes_received = $sender.Receive($bytes)
write-output ('Response = {0}',	$enc.GetString($bytes, 0, $bytes_received))
$sender.Shutdown([System.Net.Sockets.SocketShutdown]::Both)
$sender.Close()