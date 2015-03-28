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


Write-Output "# 1. Definitions "


$profile_path_relative = 'Mozilla\Firefox'
$cached_appdata = ('{0}\data\roaming\{1}' -f (Get-ScriptDirectory),$profile_path_relative)
$cached_localappdata = ('{0}\data\local\{1}' -f (Get-ScriptDirectory),$profile_path_relative)
$profile_path_appdata = ('{0}\{1}' -f $env:APPDATA,$profile_path_relative)
$profile_path_localappdata = ('{0}\{1}' -f $env:LOCALAPPDATA,$profile_path_relative)

Write-Output "# 2. Locate default profile name"

pushd $profile_path_appdata
cd 'Profiles'
$directory_name_current = (Get-ChildItem -Path '.' -Filter '*default' | Select-Object -ExpandProperty Name)


if ($directory_name_current -eq $null) {
  throw ('The profile directory was not found in {0}\Profiles' -f $profile_path_appdata)
}

$display_name = 'default'
# TODO Regexp 
$new_name = $directory_name_current -replace '^.+\.','xxxxx.'
# Use C escapes not Powershell escapes
popd
Write-Output ("default profile name: {0}" -f $directory_name_current)

Write-Output "# 3.  Compose new profiles.ini"
$new_profile = @"

[General]
StartWithLastProfile=1

[Profile0]
# The default profile should always be present
Name=default
IsRelative=1
Path=Profiles/${directory_name_current}

[Profile1]
Name=selenium
IsRelative=1
Path=Profiles/k7b0ih7r.selenium
Default=1


"@

Write-Output $new_profile


Write-Output "# 3.  Dump copy"

# TODO Transaction 
$profile_path_relative = 'Mozilla\Firefox'


$mapped_paths = @{
  $cached_appdata = $profile_path_appdata;
  $cached_localappdata = $profile_path_localappdata;

}

<#

$mapped_paths.Keys | ForEach-Object {
  $data_source_path = $_
  $data_target_path = $mapped_paths[$data_source_path]
  # Write-Output "remove-item -recurse -Path ${data_target_path} -Force -ErrorAction 'SilentlyContinue'" -filter 
  # TODO: Removal has to copy default profile
  # Remove-Item -Recurse -Path $data_target_path -Force -ErrorAction 'SilentlyContinue'

}
#>

$mapped_paths.Keys | ForEach-Object {
  $data_source_path = $_
  $data_target_path = $mapped_paths[$data_source_path]

  Write-Output "copy-item -recurse -Path ${data_source_path}  -Destination ${data_target_path} -force -errorAction 'SilentlyContinue'"
  Start-Sleep 10
  $title = "Copy profiles"
  $message = "..."
  $continue = New-Object System.Management.Automation.Host.ChoiceDescription "&YES",`
     "YES- continue"
  $skip = New-Object System.Management.Automation.Host.ChoiceDescription "&NO",`
     "NO- Skip copying"
  $options = [System.Management.Automation.Host.ChoiceDescription[]]($continue,$skip)
  $result = $host.ui.PromptForChoice($title,$message,$options,0)
  Write-Debug $result

  if ($result -eq 0) {
    Copy-Item -Recurse -Path ('{0}\*' -f $data_source_path) -Destination $data_target_path -Force -ErrorAction 'SilentlyContinue'
  }
}


Write-Output "# 4 Write new profiles.ini"

Write-Output $new_profile | Out-File -Encoding ascii -FilePath ('{0}\profiles.ini' -f $profile_path_appdata)

return

<#
 & 'D:\Program Files (x86)\Mozilla Firefox\firefox.exe'  -p Selenium
#>
