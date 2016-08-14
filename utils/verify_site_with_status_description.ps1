
<#

This script waits for the specific HTTP status and optionally checks the response headers and the response page contents.
It can be run in the console and from build system.


Sample console run:

1. DMS is down

$DebugPreference = 'Continue';
$env:MAX_RETRY_COUNT=3;
$env:CONFIRM_TEXT='DMS_IS_DOWN';
$env:EXPECTED_STATUS_DESCRIPTION='';
$env:MAX_RETRY_COUNT=3;
$env:TARGET_HOSTS_MULTIPLE='http://172.26.4.13,http://172.26.4.14,http://172.26.4.15';
$env:TARGET_PATH='keepalive.aspx';
$env:EXPECTED_STATUS_CODE=200;
. ./verify_site_with_status_description.ps1

$DebugPreference = 'Continue';
$env:CONFIRM_TEXT=$null;
$env:EXPECTED_STATUS_CODE=200;
$env:TARGET_HOSTS_MULTIPLE='http://dms.carnival.com';
$env:TARGET_PATH='tracker?referrerOverride=keepalive.aspx';
$env:EXPECTED_STATUS_DESCRIPTION='Site is unavailable';
$env:CONFIRM_TEXT= $null;


# TARGET_HOSTS_MULTIPLE=http://dms.carnival.com
# TARGET_PATH=tracker?referrerOverride=keepalive.aspx
# EXPECTED_STATUS_DESCRIPTION=Site is unavailable
# CONFIRM_TEXT=

. ./verify_site_with_status_description.ps1

1. DMS is up

$DebugPreference = 'Continue';
$env:MAX_RETRY_COUNT=3;
$env:CONFIRM_TEXT='';
$env:EXPECTED_STATUS_CODE=200;
$env:EXPECTED_STATUS_DESCRIPTION='OK';
$env:TARGET_HOSTS_MULTIPLE='http://dms.carnival.com';
$env:TARGET_PATH='tracker?referrerOverride=keepalive.aspx';
. ./verify_site_with_status_description.ps1


$DebugPreference = 'Continue';
$env:CONFIRM_TEXT='DMS_IS_UP';
$env:EXPECTED_STATUS_DESCRIPTION='';
$env:MAX_RETRY_COUNT=3;
$env:TARGET_HOSTS_MULTIPLE='http://172.26.4.13,http://172.26.4.14,http://172.26.4.15';
$env:TARGET_PATH='keepalive.aspx';
$env:EXPECTED_STATUS_CODE=200;

. ./verify_site_with_status_description.ps1

# check for status only 
$env:TARGET_HOSTS_MULTIPLE='http://dms.carnival.com';
$env:TARGET_PATH='tracker?referrerOverride=keepalive.aspx';
$env:EXPECTED_STATUS_DESCRIPTION='OK'
$env:CONFIRM_TEXT=''; # 
$env:MAX_RETRY_COUNT=3;
$env:EXPECTED_STATUS_CODE=200;
$DebugPreference = 'Continue';
. ./verify_site_with_status_description.ps1

# check for status only 
$env:TARGET_HOSTS_MULTIPLE='http://dms.carnival.com'
$env:TARGET_PATH='/';
$env:EXPECTED_STATUS_DESCRIPTION='Not Found' # cannot leave both blank
$env:CONFIRM_TEXT='';
$env:MAX_RETRY_COUNT=3;
$env:EXPECTED_STATUS_CODE=404;
$DebugPreference = 'Continue';
. ./verify_site_with_status_description.ps1

#>
param(
[string] $target_hosts  = '', 
[string] $target_path  = '', 
[string] $expected_status_code = '', 
[string] $confirm_page_text  = '', 
[string] $expected_status_description = '', 
[string] $max_retry_count = '' ,
[string] $str_verbose = $false  
)

$build_status = 'test.properties'
( $build_status ) | foreach-object {set-content -Path $_ -value ''}

$sleep_timeout  = 30
[bool] $bool_verbose  = [bool]$str_verbose
[string]$verbose_status = '' 

if ($target_path -eq '') {
	$target_path = $env:TARGET_PATH
}

if (($target_path -eq '' ) -or ($target_path -eq $null ))  {
	write-error 'The required parameter is missing: TARGET_PATH'
	exit(1)
}

if ($target_hosts -eq '') {
	$target_hosts = $env:TARGET_HOSTS_MULTIPLE
}

if (($target_hosts -eq '' ) -or ($target_hosts -eq $null ))  {
	write-error 'The required parameter is missing: TARGET_HOSTS_MULTIPLE'
	exit(1)
}

if ($expected_status_code -eq '') {
	$expected_status_code = $env:EXPECTED_STATUS_CODE
}

if (($expected_status_code -eq '' ) -or ($expected_status_code -eq $null ))  {
	write-error 'The required parameter is missing: EXPECTED_STATUS_CODE'
	exit(1)
}

if ($expected_status_description -eq '') {
	$expected_status_description = $env:EXPECTED_STATUS_DESCRIPTION
}
<#
if (($expected_status_description -eq '' ) -or ($expected_status_description -eq $null ))  {
	write-error 'The required parameter is missing: EXPECTED_STATUS_CODE'
	exit(1)
}
#>
if ($confirm_page_text -eq '') {
	$confirm_page_text = $env:CONFIRM_TEXT
}
<#
if (($confirm_page_text -eq '' ) -or ($confirm_page_text -eq $null ))  {
	write-error 'The required parameter is missing: CONFIRM_TEXT'
	exit(1)
}
#>

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


$SOLVED_UTF16_BUG = $false 

function log_message {
param(
    [Parameter(Position=0)]
    [string] $message ,
    [Parameter(Position=1)]
    [string] $logfile 
)

$timestamp = (Get-Date).ToString("yyyy/MM/dd HH:MM")

if ($SOLVED_UTF16_BUG -and $host.version.major -gt 2 ) {

  <# WARNING Tee-Object corrupts files with utf16
    PS D:\java\Jenkins\master\jobs\SQL_RUNNER_2\workspace> 
    Tee-Object  -FilePath 'test.properties' -append -InputObject 'hello world'
    hello world
    type 'test.properties' 
    h e l l o  w o r l d
  # In addition, the tee-object does not support -append option.a
  #>
  Tee-Object  -FilePath $logfile -Encoding ascii -append -InputObject $message
} else {

  write-output -InputObject ( '{0} {1}' -f $timestamp, $message )
  write-output -InputObject $message  | out-file -FilePath $logfile -Encoding ascii -Force -append
}
}

##

foreach  ( $target_host in ( $target_hosts -split ',' ) ) {

  $max_retry_count = [int]$max_retry_count
  $retry_count = 0 
  [bool]$found_expected_status =  $false 

  $target_url = ("{0}/{1}" -f $target_host, $target_path ) 
  $target_url  = $target_url -replace '//+$',  '/'

  write-host ( "Checking the status of ${target_url} with {0} retries."  -f $max_retry_count )


  write-host ( "Checking the status of ${target_url} with {0} retries."  -f $max_retry_count )
 
  while (($retry_count -lt $max_retry_count) -and ($found_expected_status -ne $true)) {
    $req = [System.Net.WebRequest]::Create($target_url)
    try {
      $res = $req.GetResponse()
    } catch [System.Net.WebException] {
      $res = $_.Exception.Response
    }

    $status_code =  [int] $res.StatusCode
    write-output  ("HTTP Status Code: {0} " -f $status_code )

    if ($status_code -eq $expected_status_code ){

      if (($confirm_page_text -eq '' ) -or ($confirm_page_text -eq $null ))  {
        # skip probing page contents
        $skip_page_contents =  $true
        # write-output  '1'
        # $found_expected_status =  $true
        $found_expected_page_contents  = $true
       } else {
         $skip_page_contents =  $false
         $found_expected_page_contents  = $false
         $found_expected_status =  $false
         $respstream = $res.GetResponseStream() 
         $stream_reader = new-object System.IO.StreamReader $respstream
         $result_page = $stream_reader.ReadToEnd()
         if ($result_page.size -lt 100 )  {
           $result_page_fragment= $result_page
         }

       if ($result_page -match $confirm_page_text) {
         $found_expected_status =  $true
         $found_expected_page_contents  = $true
         write-output  "Page Contents matches:`n${result_page_fragment}"
       } else {
         write-output  ( 'Expect   {0} "{1}"' -f 'Page contents',  $confirm_page_text )
         write-output  ( "Received {0} `n---`n{1}`n---`n" -f 'Page contents',   $result_page_fragment )
         $found_expected_page_contents  =  $false
         $result_page = ''
       }
    }

    if (($expected_status_description -eq '' ) -or ($expected_status_description -eq $null ))  {
       # skip probing .StatusDescription
       # $found_expected_status =  $true
       $found_expected_status_description =  $true
       $skip_status_description =  $true
    } else {
       $skip_status_description =  $false
       $found_expected_status =  $false
       $found_expected_status_description =  $false
       if (-not ($res.StatusDescription -match $expected_status_description) ){
         write-output  ( 'Expect   {0} "{1}"' -f 'HTTP Status Description',  $expected_status_description )
         write-output  ( 'Received {0} "{1}"' -f 'HTTP Status Description',  $res.StatusDescription )
         $found_expected_status =  $false

       } else {

         $found_expected_status =  $true
         $found_expected_status_description =  $true
         write-output   ( 'Received {0} "{1}"' -f 'HTTP Status Description',  $res.StatusDescription )
       }
    }
    } else {
      write-output  ('Waiting for HTTP status  [{0}] ' -f $expected_status_code  )
      #
    }
    $found_expected_condition = $true
    if ( $found_expected_status  -and ( $found_expected_status_description -or $found_expected_page_contents ) ){
       $found_expected_condition = $true
    }
    if (-not $found_expected_status) {     
      $retry_count++
      write-output ("Sleeping {0} sec and trying: {1}/{2} time" -f $sleep_timeout, $retry_count, $max_retry_count)
      $req = $null
      start-sleep -Seconds $sleep_timeout 
    }
  }

if (( $found_expected_status_description -and !$skip_status_description   ) -or  ( $found_expected_page_contents -and  !$skip_page_contents)) {
write-debug ("{0}={1}" -f 'found_expected_status_description' , $found_expected_status_description )
write-debug ("{0}={1}" -f 'skip_status_description' , $skip_status_description)
write-debug ("{0}={1}" -f 'found_expected_page_contents' , $found_expected_page_contents )
write-debug ("{0}={1}" -f 'skip_page_contents' , $skip_page_contents )

write-output "Verified expectations" 
   
} else {
write-output "Failed expectations" 
}

  if (-not $found_expected_status) { 

    write-output ("Have not observed HTTP status / expected page contents after {0} seconds" -f ($sleep_timeout * $max_retry_timeout ))
    log_message "STEP_STATUS=ERROR" $build_status
    write-output  'break from the loop' # there has been  loop over hosts, currently not present
    exit 0
  }

}

log_message "STEP_STATUS=OK" $build_status


<#
http://msdn.microsoft.com/en-us/library/system.net.webresponse.headers(v=vs.110).aspx

possible outcome 
Checking the status of http://dms.carnival.com/tracker?referrerOverride=keepaliv
e.aspx with 3 retries.
DEBUG: HTTP Status Code: 0
DEBUG: Waiting for HTTP status  [200]
Sleeping 30 sec and trying: 1/3 time
DEBUG: HTTP Status Code: 0
DEBUG: Waiting for HTTP status  [200]
Sleeping 30 sec and trying: 2/3 time
#>
