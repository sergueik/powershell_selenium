# http://poshcode.org/1942
function Assert {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0,ParameterSetName = 'Script',Mandatory = $true)]
    [scriptblock]$Script,
    [Parameter(Position = 0,ParameterSetName = 'Condition',Mandatory = $true)]
    [bool]$Condition,
    [Parameter(Position = 1,Mandatory = $true)]
    [string]$message)

  $message = "ASSERT FAILED: $message"
  if ($PSCmdlet.ParameterSetName -eq 'Script') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = & $Script
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }
  if ($PSCmdlet.ParameterSetName -eq 'Condition') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = $Condition
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }

  if (!$success) {
    throw $message
  }
}

# http://poshcode.org/5890
$user_choice_settings = @{
  'internet explorer' = @{ 'ftp' = 'IE.FTP'; 'http' = 'IE.HTTP'; 'https' = 'IE.HTTPS'; };
  'firefox' = @{ 'ftp' = 'FirefoxURL'; 'http' = 'FirefoxURL'; 'https' = 'FirefoxURL'; };
  'chrome' = @{ 'ftp' = 'ChromeHTML'; 'http' = 'ChromeHTML'; 'https' = 'ChromeHTML'; };
}


# Note: the HKEY_CLASSES_ROOT "hive" probably is not recognized by Powershell cmdlet 
# a.k.a. pushd : Cannot find drive. A drive with the name 'HKEY_CLASSES_ROOT' does not exist.
# a registry write to HKEY_CLASSES_ROOT is always redirected to HKLM\Software\Classes. 

$check_browser_caption = 'firefox'

$data = $user_choice_settings.Item($check_browser_caption)
$hive = 'HKLM:'
pushd $hive

$data.Keys | ForEach-Object {
  $name = $_
  $value = $data.Item($name)

  # The Easiest wat to assert the key path extists is to query the
  # default attribute that has a fixed property name '(Default)' - ignore the 'DefaultIcon' column 
  $property_name = '(Default)'
  $path =  ( '/SOFTWARE/Classes/{0}' -f $value )
  Write-Output ('Checking Settings {0} {1} {2}' -f $name , $path, $property_name )
  cd $path

  $property_value= Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $property_name -ErrorAction 'SilentlyContinue'
  $expected_value = $null
  assert -Condition ( $property_value -ne $expected_value ) -message  ( '/SOFTWARE/Classes/@{0} should not be null' )
  write-output $property_value.$property_name
}


popd
$hive = 'HKCU:'
pushd $hive
$data.Keys | ForEach-Object {
  $name = $_
  $value = $data.Item($name)
  $property_name = 'ProgId'
  $path = ('/Software/Microsoft/Windows/Shell/Associations/UrlAssociations/{0}/UserChoice' -f $name)
  cd $path
  $property_value = ( Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $property_name -ErrorAction 'SilentlyContinue' ).$property_name
  $expected_value = $value
  assert -Condition ( $property_value -eq $expected_value) -message  ( "{0}/@{1}: setting unexpected: {2}" -f   $path , $property_name , $property_value)
  <# Not resetting  the UserChoice
    if ($setting -ne $null) {
      Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
    } else {
      if ($setting -ne $value) {
        New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType DWORD

      }
    }
    #>
    write-output ( "'{0}'`t=>`t'{1}'" -f  $name,  $setting.'Progid')
}
popd

