# https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/30.0/win32/en-US/
#

Write-Host -ForegroundColor 'green' @"
This call suppresses Mozilla Maintenance services 
"@

function change_service_properties
{
param ([string] $service_name = '' , 
[string] $computer_name = $env:COMPUTERNAME 
)
$filter = 'Name=' + "'" + $service_name + "'" + '' ; 
$service = Get-WMIObject -computerName $computer_name -namespace 'root\cimv2' -class Win32_Service -Filter $filter 
$service_name = $service | select-object -ExpandProperty DisplayName
if ($service.Started){
  write-host -ForegroundColor 'green' ('Stopping service {0}'  -f $service_name ) 
  $status =   $service.StopService()
  if (($status -ne $null ) -and ($status.returnvalue  -ne '0')) { 
   $returnvalue = $status.returnvalue.ToString()
   write-output ('get unexpected returnvalue "{1}" status "{0}" ' `
   -f $returnvalue, $error_codes[$returnvalue] )
   return $false 
 } 
   while ($service.Started){
    sleep 2
    $service = Get-WMIObject -computerName $computer_name -namespace 'root\cimv2' -class Win32_Service -Filter $filter 
  }
}
  write-host -ForegroundColor 'green' ('Changing startmode service {0}'  -f $service_name ) 
  $status = $service.ChangeStartMode('Disabled')  
  if (($status -ne $null ) -and ($status.returnvalue  -ne '0')) {
   write-output ('get unexpected returnvalue {0} status "{1}" ' -f $status.returnvalue, $error_codes[$status.returnvalue.ToString()] )
   return $false 
  }
   return $true
}


change_service_properties -service_name 'MozillaMaintenance'
# The is no scheduled tasks with Firefox 

