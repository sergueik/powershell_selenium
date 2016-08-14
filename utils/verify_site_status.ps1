<#
This script waits for the specific HTTP status and checks the page contents.
It can be run in the console and from build system.

Sample run:


. ./verify_site_status.ps1  http://goccl1.syscarnival.com/keepalive/AppHealth.aspx GOCCL_DATABASE_UP 200  10


when called from build, the following environment is exected to be set

$env:TARGET_PATH='keepalive.aspx';
$env:TARGET_HOSTS_MULTIPLE='http://172.26.4.13,http://172.26.4.14,http://172.26.4.15';
$env:CONFIRM_TEXT='DMS_IS_DOWN';
$env:MAX_RETRY_COUNT=3;
$env:EXPECTED_STATUS_CODE=200;
$DebugPreference = 'Continue';
. ./verify_site_status.ps1 

#>
param(
[string] $target_path = '', 
[string] $confirm_page_text  = '', 
[string] $expected_status_code = '', 
[string] $max_retry_count = '' ,
[string] $target_hosts = '', 

[string] $str_verbose = $false  
)




$build_status = 'test.properties'
( $build_status ) | foreach-object {set-content -Path $_ -value ''}

$sleep_timeout  = 30
[bool] $bool_verbose  = [bool]$str_verbose
[string]$verbose_status = '' 

if ($target_hosts -eq '') {
	$target_hosts = $env:TARGET_HOSTS_MULTIPLE
}

if (($target_hosts -eq '' ) -or ($target_hosts -eq $null ))  {
	write-error 'The required parameter is missing: TARGET_HOSTS_MULTIPLE'
	exit(1)
}


if ($target_path -eq '') {
	$target_path = $env:TARGET_PATH
}

if (($target_path -eq '' ) -or ($target_path -eq $null ))  {
	write-error 'The required parameter is missing: TARGET_PATH'
	exit(1)
}

if ($confirm_page_text -eq '') {
	$confirm_page_text = $env:CONFIRM_TEXT
# TODO - trim surrounding quotes when found 
}
if (($confirm_page_text -eq '' ) -or ($confirm_page_text -eq $null ))  {
	write-error 'The required parameter is missing: CONFIRM_TEXT'
	exit(1)
}

if ($expected_status_code -eq '') {
	$expected_status_code = $env:EXPECTED_STATUS_CODE
}
if (($expected_status_code -eq '' ) -or ($expected_status_code -eq $null ))  {
	write-error 'The required parameter is missing: EXPECTED_STATUS_CODE'
	exit(1)
}


if ($max_retry_count -eq '') {
	$max_retry_count = $env:MAX_RETRY_COUNT
}
if ($max_retry_count -eq '') {
	$max_retry_count = 1
}

$node_name  = '' 

if ($node_name -eq '') {
	$node_name = $env:NODE_NAME
}


# http://learn-powershell.net/2011/02/11/using-powershell-to-query-web-site-information/
# http://gallery.technet.microsoft.com/scriptcenter/Powershell-Script-for-13a551b3

foreach  ( $target_host in ( $target_hosts -split ',' ) ) {
  $max_retry_count = [int]$max_retry_count
  $retry_count = 0 
  [bool]$found_expected_status =  $false 

  $target_url = ("{0}/{1}" -f $target_host, $target_path ) 

  write-host ( "Checking the status of ${target_url} with {0} retries."  -f $max_retry_count )
 
  while (($retry_count -lt $max_retry_count) -and ($found_expected_status -ne $true)) {
    $req = [System.Net.WebRequest]::Create($target_url)
    try {
      $res = $req.GetResponse()
    } catch [System.Net.WebException] {
      $res = $_.Exception.Response
    }

    $status_code =  [int] $res.StatusCode
    write-debug ("HTTP Status Code: {0} " -f $status_code )

    if ($status_code -eq $expected_status_code ){
       $respstream = $res.GetResponseStream() 
       $stream_reader = new-object System.IO.StreamReader $respstream
       $result_page = $stream_reader.ReadToEnd()
       if ($result_page -match $confirm_page_text) {
         $found_expected_status =  $true
         if ($result_page.size -lt 100 )
         {
           $result_page_fragment= $result_page
         }
           write-output "Page Contents:`n${result_page_fragment}"
       } else {
         $found_expected_status =  $false
         $result_page = ''
       }
    }
    if (-not $found_expected_status) {     
      $retry_count++
      write-output ("Sleeping {0} sec and trying: {1}/{2} time" -f $sleep_timeout, $retry_count, $max_retry_count)
      $req = $null
      start-sleep -Seconds $sleep_timeout 
    }
  }

  if (-not $found_expected_status) { 
    write-output STEP_STATUS=ERROR| out-file -FilePath $build_status -Encoding ascii -Force -append
    write-output  ("Have not observed HTTP status / expected page contents after {0} seconds" -f ($sleep_timeout * $max_retry_timeout ))
    write-debug 'break from the loop'
    exit 0
  }
}

write-output STEP_STATUS=OK| out-file -FilePath $build_status -Encoding ascii -Force -append
