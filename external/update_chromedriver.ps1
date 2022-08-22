# based on: https://swimburger.net/blog/powershell/download-the-right-chromedriver-on-windows-linux-macos-using-powershell
# only Windows part used
# see also https://www.codeofclimber.ru/2019/getting-chromedriver-updates/

[CmdletBinding()]
param (
  # NOTE: setting  the Mandatory to $true leads Powwrshell to ignore the provided value of the parameter
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
$released_chrome_driver_version = (Invoke-WebRequest "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${chrome_browser_major_version}").Content

write-output "Latest released version of Chrome Driver for Chrome browser ${chrome_browser_version} is ${released_chrome_driver_version}"
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

# NOTE: download with default options is very slow
# See: speed up Invoke-WebRequest
Invoke-WebRequest "https://chromedriver.storage.googleapis.com/$released_chrome_driver_version/chromedriver_win32.zip" -OutFile $TempZipFilePath
Expand-Archive $TempZipFilePath -DestinationPath $TempFileUnzipPath
Move-Item "$TempFileUnzipPath/chromedriver.exe" -Destination $chromedriver_path -Force
Remove-Item $TempZipFilePath
Remove-Item $TempFileUnzipPath -Recurse
