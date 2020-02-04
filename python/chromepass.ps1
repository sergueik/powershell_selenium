param (
  [String] $browser = 'chrome'
)
# https://www.pinvoke.net/default.aspx/crypt32.cryptprotectdata
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
Param(
  [string] $StoreSecret,
  [Parameter(Mandatory=$True,Position=0)]
  [string] $filename )
[void] [Reflection.Assembly]::LoadWithPartialName("System.Security")
$scope = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
if ($StoreSecret -eq "") {
  $data = Get-Content $filename
  $ciphertext = [System.Convert]::FromBase64String($data)
  # https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/security/SecureStringHelper.cs
  # internally calls CryptUnprotectData
  $plaintext = [System.Security.Cryptography.ProtectedData]::Unprotect(
    $ciphertext, $null, $scope )
  [System.Text.UTF8Encoding]::UTF8.GetString($plaintext)
} else {
  $plaintext = [System.Text.UTF8Encoding]::UTF8.GetBytes($StoreSecret)
  $ciphertext = [System.Security.Cryptography.ProtectedData]::Protect(
    $plaintext, $null, $scope )
  [System.Convert]::ToBase64String($ciphertext) > $filename
}
#>

$shared_assemblies = @(
  'System.Data.SQLite.dll', # NOTE: 'SQLite.Interop.dll' must be there too
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'
pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object {
  $shared_assembly_filename = $_
  Add-Type -Path $shared_assembly_filename
}
popd
if ($browser -eq 'vivaldi') {
  $file_path = ('C:\Users\{0}\AppData\Local\Vivaldi\User Data\Default' -f $env:username)
} else {
  $file_path = ('C:\Users\{0}\AppData\Local\Google\Chrome\User Data\Default'  -f $env:username)
}
$filename = 'Login Data'
$database = "${file_path}\${filename}"
$version = 3 # Only SQLite Version 3 is supported at this time
$connection_string = ('Data Source={0};Version={1};' -f $database,$version )
$connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
write-debug ('Opening {0}' -f $connection_string)
$connection.Open()
$datatSet = New-Object System.Data.DataSet
$query = 'SELECT action_url, username_value, password_value FROM logins'
$dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter ($query,$connection)
try {
  $dataAdapter.Fill($datatSet, 'passwords')
} catch [Exception] {
  <# database is locked ? #>
  write-output $_.Exception.Message
}

$connection.Close();
if ($datatSet.Tables.Length -eq 1) {
  [void] [Reflection.Assembly]::LoadWithPartialName('System.Security')
  $scope = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
  $rows = $datatSet.Tables['passwords'].Rows;

  $rows | foreach-object {
    $row = $_
    $row | format-list

    # action_url     : https://www.airbnb.com/create
    # username_value : kouzmine_serguei@yahoo.com
    # password_value : {1, 0, 0, 0...}
    $data = $row.password_value

    $plaindata = [System.Security.Cryptography.ProtectedData]::Unprotect( $data, $null, $scope )
    # Unable to find type [System.Security.Cryptography.ProtectedData]. - possibly run as Administrator - dont

    $plain_password_value = [System.Text.UTF8Encoding]::UTF8.GetString($plaindata)
    write-output $plain_password_value
  }
}