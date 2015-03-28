$browser = "${Env:\ProgramFiles(x86)}\Mozilla Firefox\firefox.exe";
$browserName = "firefox";
$browser_takeoff_delay = 20;
$browser_specific_arguments = ""
$runnermode_argument = ""
$runnermode_argument = ""

Write-Output "##teamcity[progressMessage  'Testing $browserName']"

Write-Output "##teamcity[progressMessage  'Setting environment']"

$Env:WORKSPACE = "${Env:\teamcity.build.checkoutDir}"
if ($Env:WORKSPACE -eq $null) {
  # TODO  - find work area of a specific product from directory.map
  $env:Workspace = $PWD;
}

# JAVA_HOME has to be in the PATH for standalone run
if ($Env:JAVA_HOME -eq $null) {
  $Env:JAVA_HOME = "C:\jre\bin"
}

$Env:STAGING = "${Env:WORKSPACE}\Staging"
$Env:TESTRSULTS = "${Env:WORKSPACE}\testResults"

Write-Output "##teamcity[progressMessage 'stopping running ${browserName} processes']"
Stop-Process -Name $browserName -ErrorAction SilentlyContinue
Start-Sleep 1

$profileDir = "$env:USERPROFILE\appdata\local\Mozilla\Firefox\Profiles"

Write-Output "##teamcity[progressMessage  'Cleaning up $browserName cache']"

$dataArray = Get-ChildItem $profileDir | ForEach-Object { $_.fullname }

foreach ($dir in $dataArray) {
  Write-Output "##teamcity[progressMessage  'Cleaning up cache directory $dir\Cache']"
  # NOTE - the following operation will fail if the Firefox  is running
  Remove-Item -Recurse -Force "$dir\Cache\*" -ErrorAction SilentlyContinue
}

Write-Output "Launched:  java.exe -jar $Env:STAGING\JSPR\Tests\JsTestDriver.jar --browser ""${browser}"" --port 4224 --tests all --basePath $Env:STAGING --testOutput $Env:TESTRSULTS --config $Env:STAGING\JSPR\Tests\JsTestDriver.conf --captureConsole"
java.exe -jar $Env:STAGING\JSPR\Tests\JsTestDriver.jar --browser "$browser" --port 4224 --tests all --basePath $Env:STAGING --testOutput $Env:TESTRSULTS --config $Env:STAGING\JSPR\Tests\JsTestDriver.conf --captureConsole

Write-Output "##teamcity[progressMessage 'Test $browserName complete']"
