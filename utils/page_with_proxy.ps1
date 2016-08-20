#Copyright (c) 2014 Serguei Kouzmine
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


param(
  [string]$username = '',
  [string]$url = 'https://haldev.service-now.com/api/now/table/change_request',
  [switch]$use_proxy,
  [string]$password = ''
)

function log_message {
  param(
    [Parameter(Position = 0)]
    [string]$message,
    [Parameter(Position = 1)]
    [string]$logfile
  )
  Write-Output -InputObject $message
  Write-Output -InputObject $message | Out-File -FilePath $logfile -Encoding ascii -Force -Append
}


function page_content {
  param(
    [string]$username = $env:USERNAME,
    [string]$url = '',
    [string]$password = '',
    [string]$use_proxy
  )

  if ($url -eq $null -or $url -eq '') {
    #  $url =  ('https://github.com/{0}' -f $username)
    $url = 'https://api.github.com/user'
  }


  $sleep_interval = 10
  $max_retries = 5
  # LEGACY log file for loading step status into Jenkins
  $build_status = 'test.properties'
  # this is a test
  $expected_status = 200


  #   ($build_status) | ForEach-Object { Set-Content -Path $_ -Value '' }

  Set-Content -Value '' -Path $build_status
  $log_file = 'healthcheck.txt'

  if ($PSBoundParameters['use_proxy']) {

    # Use current user NTLM credentials do deal with corporate firewall
    $proxy_address = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer

    if ($proxy_address -eq $null) {
      $proxy_address = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').AutoConfigURL
    }

    if ($proxy_address -eq $null) {
      # write a hard coded proxy address here 
      $proxy_address = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script'
    }

    $proxy = New-Object System.Net.WebProxy
    $proxy.Address = $proxy_address
    Write-Host ("Probing {0}" -f $proxy.Address)
    $proxy.useDefaultCredentials = $true

  }

  <#
request.Credentials = new NetworkCredential(xxx,xxx);
CookieContainer myContainer = new CookieContainer();
request.CookieContainer = myContainer;
request.PreAuthenticate = true;

#>

  [system.Net.WebRequest]$request = [system.Net.WebRequest]::Create($url)
  try {
    [string]$encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::GetEncoding('ASCII').GetBytes(($username + ':' + $password)))
    Write-Debug $encoded
    $request.Headers.Add('Authorization','Basic ' + $encoded)
  } catch [argumentexception]{

  }

  if ($PSBoundParameters['use_proxy']) {
    Write-Host ('Use Proxy: "{0}"' -f $proxy.Address)
    $request.proxy = $proxy
    $request.useDefaultCredentials = $true
  }
  # Note github returns a json result saying that it requires authentication 
  # standard server response is a "classic" 401 html page

  Write-Host ('Open {0}' -f $url)

  for ($i = 0; $i -ne $max_retries; $i++) {

    Write-Host ('Try {0}' -f $i)


    try {
      $response = $request.GetResponse()
    } catch [System.Net.WebException]{
      $response = $_.Exception.Response
    }

    $int_status = [int]$response.StatusCode
    $time_stamp = (Get-Date -Format 'yyyy/MM/dd hh:mm')
    $status = $response.StatusCode # not casting

    Write-Host "$time_stamp`t$url`t$int_status`t$status"
    # | Tee-Object  -FilePath $log_file  -append 
    if ($int_status -ne $expected_status) {
      Write-Host 'Unexpected http status detected. sleep and retry.'

      Start-Sleep -Seconds $sleep_interval

      # sleep and retry
    } else {
      break
    }
  }

  $time_stamp = $null
  if ($int_status -ne $expected_status) {
    # write error status to a log file and exit
    # 
    Write-Host ('Unexpected http status detected. Error reported. {0}, {1} ' -f $int_status)
    log_message 'STEP_STATUS=ERROR' $build_status
  }

  $respstream = $response.GetResponseStream()
  $stream_reader = New-Object System.IO.StreamReader $respstream
  $result_page = $stream_reader.ReadToEnd()
  <#
       if ($result_page -match $confirm_page_text) {
         $found_expected_status =  $true
         if ($result_page.size -lt 100 )
         {
           $result_page_fragment= $result_page
         }
           write-host "Page Contents:`n${result_page_fragment}"
       } else {
         $found_expected_status =  $false
         $result_page = ''
       }
       #>


  Write-Debug $result_page

  return $result_page

}


[string]$use_proxy_arg = $null
# TODO pass switches correctly
if ($PSBoundParameters['use_proxy']) {
  $use_proxy_arg = @( '-use_proxy',$true) -join ' '
}
Write-Host "page_content -username $username -password $password -url $url $use_proxy_arg"
page_content -UserName $username -password $password -url $url $use_proxy_arg
# write-output ( page_content -username $username -password $password -url $url $use_proxy_arg)

