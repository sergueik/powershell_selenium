# origin http://poshcode.org/2879
# http://system.data.sqlite.org/downloads/1.0.96.0/sqlite-netFx40-setup-bundle-x86-2010-1.0.96.0.exe
# If SQLite.Interop.dll is installed make sure SQLite.Interop.dll is  copied in the same directory as System.Data.SQLite.dll


$shared_assemblies = @(
  'WebDriver.dll',
  'System.Data.SQLite.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path


$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
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

$script_directory = Get-ScriptDirectory
function querySQLite {
  param([string]$query = 'SELECT * FROM logs')
  # "SELECT APPLICATION, FILENAME, AGE, TOTAL_ROWS , SELECTED_ROWS FROM LOGS WHERE  FILENAME = ?"
  $datatSet = New-Object System.Data.DataSet

  ### declare location of db file. ###
  $database = "$script_directory\logs.db"

  $connStr = "Data Source = $database"
  $conn = New-Object System.Data.SQLite.SQLiteConnection ($connStr)
  $conn.Open()

  $dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter ($query,$conn)
  [void]$dataAdapter.Fill($datatSet)

  $conn.close()
  return $datatSet.Tables[0].Rows

}

function writeSQLite {
  param([string]$query = @"

INSERT INTO logs (APPLICATION, itemNAME, AGE, RESULT, TOTAL_ROWS, SELECTED_ROWS) VALUES(?, ?, ?, ?, ?, ?)",
        undef, 
        ${item[APPLICATION]},
        ${item[FILENAME]},
        ${item[AGE]},
        ${item[RESULT]},
        ${item[TOTAL_ROWS]},
        ${item[SELECTED_ROWS]}
"@)

  $database = "$script_directory\logs.db"
  $connStr = "Data Source = $database"
  $conn = New-Object System.Data.SQLite.SQLiteConnection ($connStr)
  $conn.Open()

  $command = $conn.CreateCommand()
  $command.CommandText = $query
  $RowsInserted = $command.ExecuteNonQuery()
  $command.Dispose()
}
