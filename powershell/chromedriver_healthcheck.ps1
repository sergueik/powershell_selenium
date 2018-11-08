param(
  [string]$webdriver_dir = 'c:\\java\\selenium',
  [switch]$debug
)
$webdriver_executable = 'chromedriver.exe'
$webdriver_dir = 'c:\\java\\selenium'
$hub_url = 'http://localhost:9515/session'
$webdriver_filepath = "${webdriver_dir}\${webdriver_executable}"
$process = start-process -windowstyle hidden $webdriver_filepath -passthru
# NOTE: poweshell start-process passthru does not seem to reliably return the pid.
$id = $process.id
write-output "Chromedriver Process Id is ${id}"
$body = [byte[]][char[]]'{"desiredCapabilities":{"browserName":"chrome"}}'
$request = [System.Net.HttpWebRequest]::CreateHttp($hub_url)
$request.Method = 'POST'
$request.Timeout = 10000
$request.ContentType = 'application/json'
$stream = $request.GetRequestStream()
$stream.Write($body, 0, $body.Length)
$stream.Flush()
$stream.Close()
$response = $request.GetResponse().GetResponseStream()
$obj = convertFrom-json -InputObject ((new-object System.IO.StreamReader($response) ).ReadToEnd())
write-output ('"status":{0}' -f $obj.'status')
if ($obj.'status' -ne 0){
  write-error 'Failed to launch chrome via the chromedriver'
}
try {
  stop-process -id $id -ErrorAction stop
  write-output "Successfully killed the process with ID: ${id}"
} catch {
  write-output 'Failed to kill the chromedriver process'
}
# for CDP see https://medium.com/@dschnr/using-headless-chrome-as-an-automated-screenshot-tool-4b07dffba79a
try {
  # https://bugs.chromium.org/p/chromedriver/issues/detail?id=2311&q=&colspec=ID%20Status%20Pri%20Owner%20Summary
  # Chromedriver leaves forked Chrome instances hanging with large CPU load
  stop-process (get-process -name 'chrome') -ErrorAction stop
  write-output 'Successfully killed the chrome browser processes'
} catch {
  write-error 'Failed to kill the chrome browser process'
}
