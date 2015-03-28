$browser = "${Env:\ProgramFiles}\Google\Chrome\Application\chrome.exe"
$browserName = "chrome"
$browser_takeoff_delay = 10
$browser_specific_arguments = "--enable-logging --v=1"
$runnermode_argument = "--runnerMode DEBUG"
$runnermode_argument = ""

$Env:WORKSPACE = "${Env:\teamcity.build.checkoutDir}"
if ($Env:WORKSPACE -eq $null) {
  # TODO - find work area of a specific product from directory.map
  $env:Workspace = $PWD;
}

# JAVA_HOME has to be in the PATH for standalone run
if ($Env:JAVA_HOME -eq $null) {
  $Env:JAVA_HOME = "C:\jre\bin"
}
$Env:Path = "${Env:PATH};${Env:JAVA_HOME}"

$Env:STAGING = "${Env:WORKSPACE}\Staging"
$Env:TESTRSULTS = "${Env:WORKSPACE}\testResults"

Write-Output "##teamcity[progressMessage 'Testing ${browserName}']"

Write-Output "##teamcity[progressMessage 'stopping running ${browserName} processes']"
Stop-Process -Name $browserName -ErrorAction SilentlyContinue


Write-Output "##teamcity[progressMessage 'Clearing Chrome cache']"
# note explicit path below.
# get-childitem "${Env:LocalAppData}\Google\Chrome\User Data\Default\Cache"
Remove-Item -Recurse -Force "C:\Windows\System32\config\systemprofile\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "${Env:LocalAppData}\Google\Chrome\User Data\Default\Cache\*" -ErrorAction SilentlyContinue

Write-Output "##teamcity[progressMessage 'Clearing Chrome debug log']"

Remove-Item -Recurse -Force "${Env:LocalAppData}\Google\Chrome\User Data\chrome_debug.log" -ErrorAction SilentlyContinue

Start-Sleep 5

Write-Output "##teamcity[progressMessage 'Launching server']"
$ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo "java";
$ProcessStartInfo.Arguments = "-jar $Env:STAGING\JSPR\Tests\JsTestDriver.jar  --port 4224 --basePath $Env:STAGING --testOutput $Env:TESTRSULTS --config $Env:STAGING\JSPR\Tests\JsTestDriver.conf ${runnermode_argument}"
$ProcessStartInfo.UseShellExecute = 0;
$ProcessStartInfo.CreateNoWindow = 1;
$JSTDServerProcess = [System.Diagnostics.Process]::Start($ProcessStartInfo);
Start-Sleep -s 5

Write-Output "##teamcity[progressMessage 'Launching browser']"
$ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo $browser;
$ProcessStartInfo.Arguments = "${browser_specific_arguments} http://127.0.0.1:4224/capture";
$BrowserProcess = [System.Diagnostics.Process]::Start($ProcessStartInfo);
Write-Output "##teamcity[progressMessage 'Wait for browser to initialize']"
Start-Sleep -s $browser_takeoff_delay

Get-WmiObject win32_process -Filter "commandline like '%$browserName%'" | select processId,CommandLine | Format-Table -AutoSize -Wrap

Write-Output "##teamcity[progressMessage 'Launching log collector']"
java.exe -jar $Env:STAGING\JSPR\Tests\JsTestDriver.jar --tests all --basePath $Env:STAGING --testOutput $Env:TESTRSULTS --config $Env:STAGING\JSPR\Tests\JsTestDriver.conf --captureConsole ${runnermode_argument} 2>&1


Write-Output "##teamcity[progressMessage 'Stop browser']"
Stop-Process $BrowserProcess.Id -ErrorAction SilentlyContinue
Write-Output "##teamcity[progressMessage 'Stop java']"
Stop-Process $JSTDServerProcess.Id -ErrorAction SilentlyContinue


Write-Output "##teamcity[progressMessage 'Collecting browser debug log']"
Copy-Item -Path "${Env:LocalAppData}\Google\Chrome\User Data\chrome_debug.log" -Destination "${Env:TESTRSULTS}" -ErrorAction SilentlyContinue

Write-Output "##teamcity[buildStatus status='SUCCESS' text='{build.status.text};Test ${browserName} complete']"
