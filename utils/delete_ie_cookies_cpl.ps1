# http://www.milincorporated.com/a2_cookies.html
# http://stackoverflow.com/questions/7413966/delete-cookies-in-webdriver 

pushd "${env:USERPROFILE}\AppData\Roaming\Microsoft\Windows\Cookies"
popd
pushd "${env:USERPROFILE}\AppData\Roaming\Microsoft\Windows\Cookies\Low\"
popd
# NOTE: Recent Files in the latter directory  are present even before the browser is open first time after the cold boot.
# Session cookies ?
pushd "${env:USERPROFILE}\Local Settings\Temporary Internet Files\Content.IE5"
popd
$target_server = '...'
function clear_cookies {

  $command = 'C:\Windows\System32\rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 2'
  [void](Invoke-Expression -Command $command)
}
$target_server = $env:COMPUTERNAME
$remote_run_step = Invoke-Command -computer $target_server -ScriptBlock ${function:clear_cookies}
# note one may try to do the same using java runtime:
# http://girixh.blogspot.com/2013/10/how-to-clear-cookies-from-internet.html
<#
try {
  Runtime.getRuntime().exec("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2");
 } catch (IOException e) {
  // TODO Auto-generated catch block
  e.printStackTrace();
}
#>
