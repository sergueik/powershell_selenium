#Copyright (c) 2020,2021 Serguei Kouzmine
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
#
# automate transfer the saved passwords from Chrome or Vivaldi (Windows)
# see also: WebBrowserPassView https://www.nirsoft.net/utils/web_browser_password.html
# see also: https://github.com/xorrior/RandomPS-Scripts/blob/master/Get-FoxDump.ps1 - invokes unmanaged code from nss3.dll to decrypt saved passwords in Mozilla
# and
# https://raw.githubusercontent.com/xorrior/RandomPS-Scripts/master/Get-ChromeDump.ps1
# https://habr.com/ru/company/vdsina/blog/518416/#habracut
# https://stackoverflow.com/questions/61099492/chrome-80-password-file-decryption-in-python
param (
  # several chromium based should be supported (verified with chrome and vivaldi)
  [String]$browser = 'chrome',
  [String]$url = $null,
  [String]$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies',
  [String]$backup = 'data.bak',
  [switch]$debug
)

# NOTE: slow
$has_tee_object = $false
$backup_filepath = ((get-location).path + '\' + $backup )
if (Get-Command 'tee-object' -CommandType Cmdlet -errorAction SilentlyContinue) {
  $has_tee_object = $true
  if (test-path -path $backup_filepath){
    clear-Content -path $backup_filepath -force
  }
}

# https://www.pinvoke.net/default.aspx/crypt32.cryptprotectdata
# https://stackoverflow.com/questions/14668143/cryptunprotectdata-returns-false-when-using-jni
# https://www.codota.com/code/java/methods/com.sun.jna.platform.win32.Crypt32/CryptUnprotectData
# https://java-native-access.github.io/jna/4.2.0/com/sun/jna/platform/win32/Crypt32Util.html
# http://javadox.com/net.java.dev.jna/jna/3.5.2/index-all.html
# https://coderoad.ru/43008556/Java-CryptUnprotectData-Windows-WiFi-пароли
<#
@'

[DllImport("Crypt32.dll",SetLastError=true,  CharSet=System.Runtime.InteropServices.CharSet.Auto)]
[return: MarshalAs(UnmanagedType.Bool)]
private static extern bool CryptUnprotectData(
    ref DATA_BLOB pDataIn,
    StringBuilder szDataDescr,
    String szDataDescr,
    ref DATA_BLOB pOptionalEntropy,
    IntPtr pvReserved,
    ref CRYPTPROTECT_PROMPTSTRUCT pPromptStruct,
    CryptProtectFlags dwFlags,
    ref DATA_BLOB pDataOut
);
'@

@'
[DllImport("Crypt32.dll", SetLastError=true,CharSet=System.Runtime.InteropServices.CharSet.Auto)]
[return: MarshalAs(UnmanagedType.Bool)]
private static extern bool CryptProtectData(
    ref DATA_BLOB pDataIn,
    String szDataDescr,
    ref DATA_BLOB pOptionalEntropy,
    IntPtr pvReserved,
    ref CRYPTPROTECT_PROMPTSTRUCT pPromptStruct,
    CryptProtectFlags dwFlags,
    ref DATA_BLOB pDataOut
);

'@
#>


# see also: https://blag.nullteilerfrei.de/2018/01/05/powershell-dpapi-script/
<#
param(
  [string] $StoreSecret,
  [Parameter(Mandatory=$True,Position=0)]
  [string] $filename )
[void] [Reflection.Assembly]::LoadWithPartialName("System.Security")
$scope = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
if ($StoreSecret -eq "") {
  $data = Get-Content $filename
  $ciphertext = [System.Convert]::FromBase64String($data)
  # https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/security/SecureStringHelper.cs#L519

  # internally calls CryptUnprotectData
  #
  # uint dwFlags = CAPI.CRYPTPROTECT_UI_FORBIDDEN;
  # if (scope == DataProtectionScope.LocalMachine) { dwFlags |= CAPI.CRYPTPROTECT_LOCAL_MACHINE; }
  # CyptUnprotectData( pDataIn: new IntPtr(&dataIn), ppszDataDescr: IntPtr.Zero, pO: new IntPtr(&entropy), pvReserved: IntPtr.Zero, pPromptStruct: IntPtr.Zero, dwFlags: dwFlags, pDataBlob: new IntPtr(&userData)))
  $plaintext = [System.Security.Cryptography.ProtectedData]::Unprotect( $ciphertext, $null, $scope )
  [System.Text.UTF8Encoding]::UTF8.GetString($plaintext)
} else {
  $plaintext = [System.Text.UTF8Encoding]::UTF8.GetBytes($StoreSecret)
  $ciphertext = [System.Security.Cryptography.ProtectedData]::Protect( $plaintext, $null, $scope )
  [System.Convert]::ToBase64String($ciphertext) > $filename
}
#>

$shared_assemblies = @(
  'System.Data.SQLite.dll', # NOTE: 'SQLite.Interop.dll' must be there too
  'nunit.framework.dll'
)
# new-object : Exception calling ".ctor" with "1" argument(s):
# "An attempt was made to load a program with an incorrect format.
# (Exception from HRESULT: 0x8007007E)
# Need a x86 or x64 package named System.Data.SQLite.x86
# or System.Data.SQLite.x64
# and a matchig interop:
# https://www.nuget.org/api/v2/package/SQLite.Interop/1.0.0 for x86
# https://www.nuget.org/api/v2/package/SQLite.Interop.dll/1.0.103 for x64
# https://stackoverflow.com/questions/1001404/check-if-unmanaged-dll-is-32-bit-or-64-bit
# https://stackoverflow.com/questions/197951/how-can-i-determine-for-which-platform-an-executable-is-compiled

# SHARED_ASSEMBLIES_PATH environment overrides parameter
if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path

$shared_assemblies | foreach-object {
  $shared_assembly_filename = $_
  add-Type -Path $shared_assembly_filename
}
popd
if ($browser -eq 'vivaldi') {
  $appdata_path = ('C:\Users\{0}\AppData\Local\Vivaldi\User Data\Default' -f $env:username)
} else {
  # the password_value setting stored in this file are no longer decryptable through
  $appdata_path = ('C:\Users\{0}\AppData\Local\Google\Chrome\User Data\Default' -f $env:username)
}
# TODO
$local_state_file = $env:USERPROFILE + '\AppData\Local\Google\Chrome\User Data\Local State'
write-output ('Reading {0}' -f $local_state_file )
$local_state = get-content -literalpath $local_state_file -encoding utf8
$local_state | out-file 'a.j.json' -encoding utf8
# $local_state = select-string -literalpath $local_state_file -encoding utf8 -pattern '.*'
try {
  $local_state_object = convertfrom-json -inputobject $local_state
} catch [Exception] {
  # convertfrom-json : Cannot process argument because the value of argument "name" is not valid.
  # Change the value of the "name" argument and run the

}
# jq:
# parse error: Invalid numeric literal at line 1, column 3: wrong encoding
# c:\tools\jq-win64.exe -cr '.os_crypt.encrypted_key' a.j.json - get the key
$encrypted_key = '...'
$scope = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
$optional_entropy = [Byte[]]@()
[void]($plain_key = [System.Security.Cryptography.ProtectedData]::Unprotect( [System.Convert]::FromBase64Stng($encrypted_key), $optional_entropy, $scope ))
# Exception calling "Unprotect" with "3" argument(s): "Unable to update the password. The value provided for the new password does not meet the length,complexity, or history requirements of the domain.
$filename = 'Login Data'
$database = "${appdata_path}\${filename}"
$version = 3 # the only supported SQLite version at this time is 3
$connection_string = ('Data Source={0};Version={1};' -f $database,$version )
$connection = new-object System.Data.SQLite.SQLiteConnection ($connection_string)
if ($debug){
  write-output ('Opening {0}' -f $connection_string)
}
# TODO: check if browser is running
$connection.Open()
$datatSet = new-object System.Data.DataSet
$query = 'SELECT action_url, username_value, password_value FROM logins'
if ($url -ne $null) {
  $where = (" where action_url like '%{0}%'" -f $url )
} else {
  $where = ''
}
$dataAdapter = new-object System.Data.SQLite.SQLiteDataAdapter ($query,$connection)
try {
  $dataAdapter.Fill($datatSet, 'passwords')
} catch [Exception] {
  if ($debug) {
    write-output $_.Exception.Message
  }
  if ($_.Exception.Message -match 'database is locked') {
    write-output ('you probably need to close the browser' -f $browser )
  }
}

$connection.Close()

[System.Collections.ArrayList]$result_array = @()
$result = new-object -typename psobject

if ($datatSet.Tables.Length -eq 1) {

  $rows = $datatSet.Tables['passwords'].Rows

  $rows | foreach-object {
    $row = $_

    if ($url -eq $null -or $row.action_url -match $url) {
      if ($debug) {
        $row | format-list
      }
      $result = new-object -typename psobject
      # https://www.gngrninja.com/script-ninja/2016/6/18/powershell-getting-started-part-12-creating-custom-objects
      add-member -inputobject $result -membertype NoteProperty -name url -value $row.action_url
      add-member -inputobject $result -membertype NoteProperty -name user -value $row.username_value
      $encrypted_data = $row.password_value
      [void] [Reflection.Assembly]::LoadWithPartialName('System.Security')
      $scope = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
      $optional_entropy = [Byte[]]@()
      # optional additional byte array that was used to encrypt the data
      # https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.protecteddata.unprotect?view=netframework-4.0
      # https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.dataprotectionscope?view=netframework-4.0
      try {
        if ($debug) {
          write-output ('try to unprotect the encrypted data')
        }
        [void]($plaindata = [System.Security.Cryptography.ProtectedData]::Unprotect( $encrypted_data, $optional_entropy, $scope ))
        if ($debug) {
          write-output ('got plaindata')
        }
        # Unable to find type [System.Security.Cryptography.ProtectedData]. - this script should not be run as Administrator

        $plain_password_value = [System.Text.UTF8Encoding]::UTF8.GetString($plaindata)
        if ($debug) {
          write-output ('got plain password value')
        }
        add-member -inputobject $result -membertype NoteProperty -name password -value $plain_password_value
        if ($debug) {
          write-output $plain_password_value
        }
        $result_array.Add($result) | out-null
      } catch [Exception] {
        if ($debug) {
          # NOTE: issues with formatting
          # write-output ("Exception:`r`n{0} ...`r`n(ignored)" -f (($_.Exception.Message) -split "`r`n")[0])
          write-output ("Exception (ignored):`r`n{0}" -f $_.Exception.Message)
        }
      }
    }
  }
}
if ($has_tee_object) {
  # NOTE: bug? swapping the format-list with tee-object will make only first column of every $result row backed up into the file
  $result_array | where-object { $_.url -ne ''}  |format-list | tee-object -filepath $backup_filepath
} else {
  $result_array | where-object { $_.url -ne ''} | format-list
}

