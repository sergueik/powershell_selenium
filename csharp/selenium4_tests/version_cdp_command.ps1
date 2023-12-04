#Copyright (c) 2023 Serguei Kouzmine
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

# basic CDP command demo. NOTE: working through $session can be complex

param(
  [switch]$headless
)

$webDriver_version = '4.8.2' 
# NOTE: on Windows 7 and Windows 8 this is the highest version one can use 
# because Chrome is Version 109.0.5414.168
# To get later Google Chrome updates, need OS upgrade to Windows 10 or later
add-type -path .\packages\Selenium.WebDriver.4.8.2\lib\net45\WebDriver.dll
$env:Path += ";${env:USERPROFILE}\Downloads"
$options = new-object OpenQA.Selenium.Chrome.ChromeOptions
if( $PSBoundParameters['headless'].IsPresent) {
  $options.AddArgument('--headless')
}
$driver = new-object OpenQA.Selenium.Chrome.ChromeDriver($options)

$session = ([OpenQA.Selenium.DevTools.IDevTools]$driver).GetDevToolsSession() 
# unused
$session.SendCommand

<# 
OverloadDefinitions
-------------------
System.Threading.Tasks.Task[OpenQA.Selenium.DevTools.ICommandResponse[TCommand]] SendCommand[TCommand](TCommand command, System.Threading.CancellationToken cancellationToken, System.Nullable[int] millisecondsTimeout, bool throwExceptionIfResponseNotReceived)
System.Threading.Tasks.Task[TCommandResponse] SendCommand[TCommand, TCommandResponse](TCommand command, System.Threading.CancellationToken cancellationToken, System.Nullable[int] millisecondsTimeout, bool throwExceptionIfResponseNotReceived)
System.Threading.Tasks.Task`1[[Newtonsoft.Json.Linq.JToken, WebDriver, Version=4.0.0.0, Culture=neutral, PublicKeyToken=null]], mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089 SendCommand(string commandName, Newtonsoft.Json.Linq.JToken, WebDriver, Version=4.0.0.0, Culture=neutral, PublicKeyToken=null commandParameters, System.Threading.CancellationToken cancellationToken, System.Nullable[int] millisecondsTimeout, bool throwExceptionIfResponseNotReceived)
System.Threading.Tasks.Task[OpenQA.Selenium.DevTools.ICommandResponse[TCommand]] IDevToolsSession.SendCommand[TCommand](TCommand command, System.Threading.CancellationToken cancellationToken, System.Nullable[int] millisecondsTimeout, bool throwExceptionIfResponseNotReceived) System.Threading.Tasks.Task[TCommandResponse] IDevToolsSession.SendCommand[TCommand, TCommandResponse](TCommand command, System.Threading.CancellationToken cancellationToken, System.Nullable[int] millisecondsTimeout, bool throwExceptionIfResponseNotReceived)
System.Threading.Tasks.Task`1[[Newtonsoft.Json.Linq.JToken, WebDriver, Version=4.0.0.0, Culture=neutral, PublicKeyToken=null]], mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089 IDevToolsSession.SendCommand(string commandName, Newtonsoft.Json.Linq.JToken, WebDriver, Version=4.0.0.0, Culture=neutral, PublicKeyToken=null params, System.Threading.CancellationToken cancellationToken, System.Nullable[int] millisecondsTimeout, bool throwExceptionIfResponseNotReceived)
#>

$driver.executeCdpCommand('Browser.getVersion',@{}) | format-list

<#
Key   : jsVersion
Value : 10.9.194.17

Key   : product
Value : HeadlessChrome/109.0.5414.168

Key   : protocolVersion
Value : 1.3

Key   : revision
Value : @932ffddafa9ddc65da0b5b1693b3d3492a70893f

Key   : userAgent
Value : Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML,
        like Gecko) HeadlessChrome/109.0.5414.168 Safari/537.36
#>

$driver.close()
$driver.quit()
