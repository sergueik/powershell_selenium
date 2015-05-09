# origin http://poshcode.org/2879
# http://system.data.sqlite.org/downloads/1.0.96.0/sqlite-netFx40-setup-bundle-x86-2010-1.0.96.0.exe
# If SQLite.Interop.dll is installed make sure SQLite.Interop.dll is  copied in the same directory as System.Data.SQLite.dll



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

function init_database {
  param([string]$database = 'log.db'
  )

  [System.Data.SQLite.SQLiteConnection]::CreateFile($database)
  [int]$version = 3
  $connection = New-Object System.Data.SQLite.SQLiteConnection (('Data Source={0};Version={1};' -f $database,$version))
  $connection.Open()
  $command = $connection.CreateCommand()
  # $command.getType() | format-list
  $connection.Close()
}

function create_table {
  param([string]$database = 'shore_ex.db',

    # http://www.sqlite.org/datatype3.html
    [string]$create_table_query = @"
   CREATE TABLE IF NOT EXISTS [destinations]
      (CODE       CHAR(16) PRIMARY KEY     NOT NULL,
         URL      CHAR(1024),
         CAPTION   CHAR(256),
         STATUS    INTEGER   NOT NULL
      );

"@
  )
  [int]$version = 3
  $connection = New-Object System.Data.SQLite.SQLiteConnection ('Data Source={0};Version={1};' -f $database,$version)
  $connection.Open()
  Write-Output $create_table_query
  [System.Data.SQLite.SQLiteCommand]$sql_command = New-Object System.Data.SQLite.SQLiteCommand ($create_table_query,$connection)
  $sql_command.ExecuteNonQuery()
  $connection.Close()


}


function query_database_basic {
  param(
    [string]$query = 'SELECT CAPTION, URL, CODE FROM destinations',
    [string]$database = "$script_directory\shore_ex.db"
  )
  $connectionStr = "Data Source = $database"
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connectionStr)
  $connection.Open()
  $datatSet = New-Object System.Data.DataSet

  $dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter ($query,$connection)
  [void]$dataAdapter.Fill($datatSet)
  $connection.Close()
  return $datatSet.Tables[0].Rows
}


function query_database {
  param(
    [string]$query = 'SELECT URL, CAPTION, CODE  FROM destinations WHERE CAPTION = ?',
    [string]$database = "$script_directory\shore_ex.db",
    [string]$destination = 'Ensenada',
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null),
    [object]$fields = @(),
    [bool]$debug
  )
  try {
    $fields | Get-Member
  } catch [exception]{}


  $connectionStr = "Data Source = $database"
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connectionStr)
  [void]$connection.Open()
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $local:result = @()
  $caption = New-Object System.Data.SQLite.SQLiteParameter
  [void]$command.Parameters.Add($caption)
  $caption.Value = $destination

  [System.Data.SQLite.SQLiteDataReader]$sql_reader = $command.ExecuteReader()
  <#     Exception calling "Fill" with "1" argument(s): "unknown error Insufficient parameters supplied to the command"
   #>

  try
  {
    Write-Debug 'Reading'
    while ($sql_reader.Read())
    {
      Write-Debug ($sql_reader.GetString(0))
      Write-Debug ($sql_reader.GetString(1))

      if ($fields.count -gt 0) {
        Write-Debug 'ordilnal'
        Write-Debug $fields.count
        $iterator = 0..($fields.count - 1)
        <#
         ForEach-Object : Cannot convert 'System.Object[]' to the type 'System.String' required by parameter 'Message'. Specified method is not supported.
        #>
        $iterator | ForEach-Object {
          $cnt = $_
          $field = $fields[$cnt]
          $debug_msg = ('ordilnal({0} = {1}',$field,$sql_reader.GetOrdinal($field))
          Write-Debug $debug_msg
          $local:result += $sql_reader.GetOrdinal($field)

        }
      } else {
        Write-Debug 'field'
        $local:result += $sql_reader.GetString(0)
      }

    }
  }
  finally
  {
    $sql_reader.Close()
    $connection.Close()
  }
  $result_ref.Value = $local:result

}


# http://www.devart.com/dotconnect/sqlite/docs/parameters.html
function udate_database {
  param(
    [string]$database = "$script_directory\logs.db",
    [string]$query = @"
UPDATE [destinations] SET URL = @url, STATUS = :status WHERE CODE = @code
-- can use @  or :   
"@,
    [psobject]$data
  )

  $connectionStr = "Data Source = $database"
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connectionStr)
  $connection.Open()
  Write-Output $query
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $code = New-Object System.Data.SQLite.SQLiteParameter
  $caption = New-Object System.Data.SQLite.SQLiteParameter
  $url = New-Object System.Data.SQLite.SQLiteParameter
  $status = New-Object System.Data.SQLite.SQLiteParameter

  $parameter_1 = New-Object System.Data.SQLite.SQLiteParameter
  $parameter_1 | get-member
  $command.Parameters.Add($parameter_1)
  $parameter_1.Value = "xzzz"
  $parameter_1.ParameterName= "@code"

  $parameter_2 = New-Object System.Data.SQLite.SQLiteParameter
  $parameter_2 | get-member
  $command.Parameters.Add($parameter_2)
  $parameter_2.Value = "new url"
  $parameter_2.ParameterName= "@url"

  $parameter_3 = New-Object System.Data.SQLite.SQLiteParameter
  $parameter_3 | get-member
  $command.Parameters.Add($parameter_3)
  $parameter_3.Value = 0
  $parameter_3.ParameterName= "status"

  $rows_inserted = $command.ExecuteNonQuery()
  <#
   Syntax errors manifest themsels via 
   Exception calling "ExecuteNonQuery" with "0" argument(s): "SQL logic error or missing database" 
  #>
  Write-Output $rows_inserted
  $command.Dispose()
}



function insert_database {
  param(
    [string]$database = "$script_directory\logs.db",
    [string]$query = @"
INSERT INTO [destinations] (CODE, CAPTION, URL, STATUS )  VALUES(?, ?, ?, ?)
"@,
    [psobject]$data
  )


  $connectionStr = "Data Source = $database"
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connectionStr)
  $connection.Open()
  Write-Output $query
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $code = New-Object System.Data.SQLite.SQLiteParameter
  $caption = New-Object System.Data.SQLite.SQLiteParameter
  $url = New-Object System.Data.SQLite.SQLiteParameter
  $status = New-Object System.Data.SQLite.SQLiteParameter


  $command.Parameters.Add($code)
  $command.Parameters.Add($caption)
  $command.Parameters.Add($url)
  $command.Parameters.Add($status)

  $code.Value = $data.code
  $caption.Value = $data.caption
  $url.Value = $data.url
  $status.Value = $data.status
  $rows_inserted = $command.ExecuteNonQuery()
  Write-Output $rows_inserted
  $command.Dispose()
}


$shared_assemblies = @(
  'System.Data.SQLite.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path


$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd
$script_directory = Get-ScriptDirectory
# suppressed query
query_database
# TODO: exception
init_database -database "$script_directory\destinations.db"
# full path  has to be provided
create_table -database "$script_directory\destinations.db"
$array = New-Object System.Collections.ArrayList
$o = New-Object PSObject
$o | Add-Member Noteproperty 'code' 'zzz'
$o | Add-Member Noteproperty 'url' 'http://www.google.com'
$o | Add-Member Noteproperty 'caption' 'this is a caption'
$o | Add-Member Noteproperty 'status' 0
$array.Add($o)


# insert_database -data $o -database "$script_directory\destinations.db"

# https://www.connectionstrings.com/sqlite/
udate_database -database "$script_directory\destinations.db"

query_database -database "$script_directory\destinations.db"
