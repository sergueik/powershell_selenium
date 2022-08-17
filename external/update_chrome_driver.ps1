#Copyright (c) 2022 Kouzmine
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


# based on: https://swimburger.net/blog/powershell/download-the-right-chromedriver-on-windows-linux-macos-using-powershell
# only Windows part used
# see also https://www.codeofclimber.ru/2019/getting-chromedriver-updates/

[CmdletBinding()]
param (
  # NOTE: setting  the Mandatory to $true leads Powershell to ignore the provided value of the parameter
  #[Parameter(Mandatory = $true)]
  [Parameter(Mandatory = $false)]
  [string]
  $chromedriver_path = "${env:USERPROFILE}\Downloads",    
  [Parameter(Mandatory = $false)]
  [string]
  $chrome_browser_version, 
  [Parameter(Mandatory = $false)]
  [Switch]
  $force
)



try {
  $chrome_browser_version =  (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe' -ErrorAction Stop).'(Default)').VersionInfo.FileVersion
} catch {
  throw "Google Chrome not found in registry"
}

$chrome_browser_major_version = $chrome_browser_version.Substring(0, $chrome_browser_version.LastIndexOf('.'))

$url = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${chrome_browser_major_version}"
write-output "Reading chrome driver version from ${url}"
$WebRequest = New-Object System.Net.WebClient
$Data = $WebRequest.DownloadData($url)
$released_chrome_driver_version = [System.Text.Encoding]::ASCII.GetString($Data)

write-output "Latest released version of Chrome Driver for Chrome browser ${chrome_browser_version} is ${released_chrome_driver_version}"
# NOTE: this approach will not work for Windows XP last supported Chrome version 49:
# the url https://chromedriver.storage.googleapis.com/LATEST_RELEASE_49.0.2623
# 404
# 2.41 is the oldest chrome driver version listed on
# https://chromedriver.chromium.org/downloads
# it is said to support Chrome v67-69
# on https://chromedriver.storage.googleapis.com/index.html there are older releases 2.0 through 2.46
# note this page is generated and can only be saved via dev tools
# all cells in the table look like
# <tr>
# <td valign="top">
# <img src="/icons/folder.gif" alt="[DIR]"></td>
# <td><a href="?path=2.1/">2.1</a></td>
# <td align="right">-</td>
# <td align="right">-</td>
# <td align="right">-</td>
# </tr>
# so it is easy to construct the link https://chromedriver.storage.googleapis.com/index.html?path=2.5/
# and https://chromedriver.storage.googleapis.com/2.5/notes.txt
# to check the supported version
# each notes.txt documents a range of versions older than the one in its url
# for Chrome version 49 the correspondent chromedriver version is 2.22 or 2.21
# https://chromedriver.storage.googleapis.com/2.22/chromedriver_win32.zip
#
$TempFilePath = [System.IO.Path]::GetTempFileName()
$TempZipFilePath = $TempFilePath.Replace('.tmp', '.zip')
Rename-Item -Path $TempFilePath -NewName $TempZipFilePath
$TempFileUnzipPath = $TempFilePath.Replace('.tmp', '')

if (-Not (Test-Path $chromedriver_path -PathType Container)) {
  $dir = New-Item -ItemType directory -Path $chromedriver_path
}

if (Test-Path "${chromedriver_path}\chromedriver.exe" -PathType Leaf) {
  # get version of current chromedriver.exe
  $output = (& "${chromedriver_path}\chromedriver.exe" --version)
  # 104.0.5112.79 (3cf3e8c8a07d104b9e1260c910efb8f383285dc5-refs/branch-heads/5112@{#1307})
  $found = $output -match '\b([0-9.]+)\b'
  if ($found) {
    $installed_chrome_driver_file_version = $matches[1]
  } else {
    $installed_chrome_driver_file_version = $output
  }
  write-output "Installed version of Chrome Driver is ${installed_chrome_driver_file_version}"
}
if ($installed_chrome_driver_file_version -eq $released_chrome_driver_version) { 
  write-output 'Already installed'
  if (-not $force) {
    return
  } else { 
    write-output 'Reinstalling'
  }
}

# https://stackoverflow.com/questions/25120703/invoke-webrequest-equivalent-in-powershell-v2
$url = "https://chromedriver.storage.googleapis.com/$released_chrome_driver_version/chromedriver_win32.zip"
write-output "Downloading chrome driver from ${url}"
# PowerShell 2 version
$WebRequest = New-Object System.Net.WebClient
$WebRequest.UseDefaultCredentials = $true
$Data = $WebRequest.DownloadData($url)
remove-item -path $TempZipFilePath
[System.IO.File]::WriteAllBytes($TempZipFilePath ,$Data)

Expand-Archive $TempZipFilePath -DestinationPath $TempFileUnzipPath
write-output "move-item ""$TempFileUnzipPath\chromedriver.exe"" -Destination $chromedriver_path -confirm:`$false"
remove-item -path "${chromedriver_path}\chromedriver.exe"
# move-item : Cannot create a file when that file already exists
move-item "$TempFileUnzipPath\chromedriver.exe" -Destination "$chromedriver_path\chromedriver.exe" -confirm:$false
Remove-Item $TempZipFilePath
Remove-Item $TempFileUnzipPath -Recurse
