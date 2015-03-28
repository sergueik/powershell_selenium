#Copyright (c) 2014 Serguei Kouzmine
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

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot;
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'));
  }
}

$shared_assemblies = @(
  'ThoughtWorks.Selenium.Core.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)
$env:SHARED_ASSEMBLIES_PATH = 'c:\developer\sergueik\csharp\SharedAssemblies'


$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


# This is a Selenium RC Poweshell transaction. It can be used to develop Powershell Formatter IDE.
# Note: Selenium RC (legacy) protocol is not supported by headless drivers (it is not a problem on Linux w/xvfb)
# http://yizeng.me/2014/04/25/relationships-between-different-versions-of-selenium
# http://www.studyselenium.com/2014/01/difference-between-selenium-rc-and.html


try {
  $connection = (New-Object Net.Sockets.TcpClient)
  $connection.Connect('127.0.0.1',4444)
  $connection.Close()
}
catch {
  # https://gist.github.com/empo/958531
  $selemium_driver_folder = 'c:\java\selenium'
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\hub.cmd"
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\node.cmd"
  Start-Sleep 10

}

$verificationErrors = New-Object System.Text.StringBuilder
$selenium = New-Object Selenium.DefaultSelenium ('localhost',4444,'*firefox','http://www.wikipedia.org/')
$selenium.Start()
$selenium.Open('/')
$selenium.Click('css=strong')
$selenium.WaitForPageToLoad('30000')
$selenium.Type('id=searchInput','selenium')
$selenium.Click('id=searchButton')
$selenium.WaitForPageToLoad('30000')
$selenium.Click('link=Selenium (software)')
$selenium.WaitForPageToLoad('30000')

[NUnit.Framework.Assert]::AreEqual($selenium.GetTitle(),'Selenium (software) - Wikipedia, the free encyclopedia')
Start-Sleep -Seconds 240
try {
  $selenium.Stop()
} catch [exception]{
  # Ignore errors if unable to close the browser
}

[NUnit.Framework.Assert]::AreEqual('',$verificationErrors.ToString())
