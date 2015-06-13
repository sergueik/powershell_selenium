#Copyright (c) 2014,2015 Serguei Kouzmine
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

function fiddlercore_locator {
  # makecert.exe is installed by FiddlerCode 
  # TODO: modify package.nuget
  # another option is to find makecert.exe in Microsoft Windows SDK directory
  # Program Files\Microsoft SDKs\Windows\v7.0A\bin\makecert.exe
  if (-not [environment]::Is64BitProcess) {
    # TODO: verify on 64 bit machine
    $path = '/Software/Telerik/FiddlerCoreAPI/'
  } else {
    $path = '/Software/Telerik/FiddlerCoreAPI/'
  }

  [string]$InstallPath = $null
  $hive = 'HKCU:'
  [string]$name = $null
  pushd $hive
  cd $path
  $name = 'InstallPath'
  $result = Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)
  try {
    $InstallPath = $result.InstallPath
  } catch [exception]{

  }
  Write-Debug ('InstallPath :  {0}' -f $InstallPath)
  popd
  return $InstallPath
}
