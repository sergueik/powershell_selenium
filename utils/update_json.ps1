param(
  [string]$target_host = '',
  [string]$json_template = 'NODE_config_FF_IE_CH_Port5555.json',
  [string]$result_json = 'NODE_config_FF_IE_CH_Port5555.json',
  [string]$selenium_folder = 'c:\selenium-dotnet',
  [string]$hub_host = '172.25.176.176',
  [int]$hub_port = 4444,
  [string]$ie_version = '9',
  [switch]$test,
  [switch]$debug
)



# The filename of the json is locked because it is used in the batch file
# thich in turn is used in the Windows Task XML

if ($target_host -eq '') {
  $target_host = $env:TARGET_HOST
}

if (($target_host -eq '') -or ($target_host -eq $null)) {
  Write-Error 'The required parameter is missing : TARGET_HOST'
  exit (1)
}

[string]$node_host = ''

# Production run users the same basename but differnt path and / or host 
# for template and final json
# Test run creates a file locally (same host , script path )

if ($PSBoundParameters["test"]) {
  $result_json = ('{0}\{1}' -f (Get-ScriptDirectory),'test.json')
  $node_host = $env:COMPUTERNAME
}

else {

  $node_host = $target_host
  $result_json = ('{0}\{1}' -f $selenium_folder,$result_json)
  $json_template = ('{0}\{1}' -f $selenium_folder,$json_template)

}
if ($hub_host -eq '') {
  $hub_host = $env:HUB_HOST
}

if (($hub_host -eq '') -or ($hub_host -eq $null)) {
  Write-Error 'The required parameter is missing : HUB_HOST'
  exit (1)
}


if ($hub_port -eq '') {
  $hub_port = $env:HUB_PORT
}

if (($hub_port -eq '') -or ($hub_port -eq $null)) {
  Write-Error 'The required parameter is missing : HUB_PORT'
  exit (1)
}

if ($node_host -eq '') {
  $node_host = $env:NODE_HOST
}

if (($node_host -eq '') -or ($node_host -eq $null)) {
  Write-Error 'The required parameter is missing : NODE_HOST'
  exit (1)
}

# TODO : copy template to $target_host:

function fix_json_file {
  param(
    [string]$json_template = 'NODE_config_FF_IE_CH_Port5555.json',
    [string]$result_json = 'NODE_config_FF_IE_CH_Port5555.json',
    [string]$selenium_folder = 'c:\selenium-dotnet',
    [string]$hub_host,
    [int]$hub_port,
    [string]$node_host,
    [string]$ie_version,
    [switch]$test
  )


  # http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
  function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSScriptRoot) {
      $Invocation.PSScriptRoot
    }
    elseif ($Invocation.MyCommand.Path) {
      Split-Path $Invocation.MyCommand.Path
    } else {
      $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
    }
  }

  Write-Output ('Creating folder "{0}"' -f $selenium_folder)
  if (-not (Get-Item -Path $selenium_folder -ErrorAction 'SilentlyContinue')) {
    Write-Output ('Creating folder "{0}"' -f $selenium_folder)
    New-Item -Path $selenium_folder -ErrorAction 'SilentlyContinue' -Type 'Directory'
  }
  # TODO:
  # Template has to reside on the same machine as result
  $result = (Get-Content -Path $json_template) -join "`n"
  $json_object = ConvertFrom-Json -InputObject $result
  $json_object.configuration.hubHost = $hub_host
  $json_object.configuration.hubPort = $hub_port
  $configuration_object = $json_object.configuration
  Add-Member -InputObject $configuration_object -NotePropertyName 'host' -NotePropertyValue '' -Force
  $json_object.configuration = $configuration_object
  $json_object.configuration.host = $node_host
  if (($ie_version -ne '') -and ($ie_version -ne $null)) {

    $capabilities_object = $json_object.capabilities
    $target_index = $null
    $cnt = 0

    $capabilities_object | ForEach-Object {

      $entry = $_
      if ($entry.browserName -match 'internet explorer') {
        Write-Output ("Providing specific version information to`n")
        $json_object.capabilities[$cnt] | Format-List
        $target_index = $cnt
      }
      $cnt = $cnt + 1
    }
    $json_object.capabilities[$target_index].version = $ie_version
    Write-Output $json_object.capabilities[$target_index]
  } else {
    Write-Output 'Keeping the default IE version'
  }


  Write-Output ('Truncate the file "{0}"' -f $result_json)

  '' | Out-File -FilePath $result_json -Encoding ascii -Force
  Write-Output ('Saving new contents to the file "{0}"' -f $result_json)
  ConvertTo-Json -InputObject $json_object | Out-File -FilePath $result_json -Encoding ascii -Force -Append


}

$remote_run_step1 = Invoke-Command -computer $target_host -ScriptBlock ${function:fix_json_file} -ArgumentList $json_template,$result_json,$selenium_folder,$hub_host,$hub_port,$node_host,$ie_version,$test

Write-Output $remote_run_step1
<#

if (-not ($PSBoundParameters['test'])) {
  $remote_run_step2 = Invoke-Command -computer $target_host -ScriptBlock ${function:restart_tast}
  Write-Output $remote_run_step2
}

#>
