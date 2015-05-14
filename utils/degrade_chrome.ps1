Write-Host -ForegroundColor 'green' @"
This call suppresses Chrome update services 
"@


function change_service_properties
{
  param([string]$service_name = '',
    [string]$computer_name = $env:COMPUTERNAME
  )
  $filter = 'Name=' + "'" + $service_name + "'" + '';
  $service = Get-WmiObject -ComputerName $computer_name -Namespace 'root\cimv2' -Class Win32_Service -Filter $filter
  $service_name = $service | Select-Object -ExpandProperty DisplayName
  if ($service.Started) {
    Write-Host -ForegroundColor 'green' ('Stopping service {0}' -f $service_name)
    $status = $service.StopService()
    if (($status -ne $null) -and ($status.returnvalue -ne '0')) {
      $returnvalue = $status.returnvalue.ToString()
      Write-Output ('get unexpected returnvalue "{1}" status "{0}" ' `
           -f $returnvalue,$error_codes[$returnvalue])
      return $false
    }
    while ($service.Started) {
      sleep 2
      $service = Get-WmiObject -ComputerName $computer_name -Namespace 'root\cimv2' -Class Win32_Service -Filter $filter
    }
  }
  Write-Host -ForegroundColor 'green' ('Changing startmode service {0}' -f $service_name)
  $status = $service.ChangeStartMode('Disabled')
  if (($status -ne $null) -and ($status.returnvalue -ne '0')) {
    Write-Output ('get unexpected returnvalue {0} status "{1}" ' -f $status.returnvalue,$error_codes[$status.returnvalue.ToString()])
    return $false
  }
  return $true
}

change_service_properties -service_name 'gupdate'
change_service_properties -service_name 'gupdatem'

Write-Host -ForegroundColor 'green' @"
This call deletes Chrome update scheduled  tasks (may already be deleted).
"@

Invoke-Expression -Command "C:\Windows\System32\schtasks.exe /delete  /f /tn:GoogleUpdateTaskMachineCore" -ErrorAction 'SilentlyContinue'
Invoke-Expression -Command "C:\Windows\System32\schtasks.exe /delete  /f /tn:GoogleUpdateTaskMachineUA" -ErrorAction 'SilentlyContinue'

Write-Host -ForegroundColor 'green' @"
This call sets Chrome update check period to '0'
"@

$hive = 'HKLM:' # TODO  link to Google document
$path = '/SOFTWARE/Policies/Google/Update'
$name = 'AutoUpdateCheckPeriodMinutes'

pushd $hive
cd '/SOFTWARE/Policies'
New-Item -Path 'Google' -ErrorAction 'SilentlyContinue'
cd '/SOFTWARE/Policies/Google'
New-Item -Path 'Update' -ErrorAction 'SilentlyContinue'
cd $path
Remove-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -ErrorAction 'SilentlyContinue'

[void](New-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -Value '0' -PropertyType DWORD)
$result = (Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)).AutoUpdateCheckPeriodMinutes
Write-Output ('Changed setting {0} to {1}' -f ('{0}/{1}' -f $hive,$path),$result)
popd

<#

function killall
{
param ([string] $program_name = '' , 
[string] $computer_name = $env:COMPUTERNAME 
)
$filter = 'Commandline like' + "'%" + $program_name + "%'" ; 
$processes = Get-WMIObject -computerName $computer_name -namespace 'root\cimv2' -class Win32_process -Filter $filter 
if ($processes -ne $null -and $processes.Count -gt 0 ) {
$processes | foreach-object {write-output $_.ProcessId} 
$processes | foreach-object {$_.terminate()} 
#TODO: assert 
   return $true
} else {

return $false }

}

[void](killall -program_name 'chrome.exe')

remove-item "${env:LOCALAPPDATA}\Google\Chrome\User Data" -recurse -force -erroraction 'SilentlyContinue'
#>
