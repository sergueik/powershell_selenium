#Copyright (c) 2015 Serguei Kouzmine
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
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}

function init_database {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db"
  )

  [System.Data.SQLite.SQLiteConnection]::CreateFile($database)
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  $command = $connection.CreateCommand()
  # $command.getType() | format-list
  $connection.Close()
}

function create_table {

  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$create_table_query = @"
   CREATE TABLE IF NOT EXISTS [destinations]
      (
         CODE      CHAR(16) PRIMARY KEY     NOT NULL,
         URL       CHAR(1024),
         CAPTION   CHAR(256),
         STATUS    INTEGER   NOT NULL
      );
"@ # http://www.sqlite.org/datatype3.html
  )
  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  Write-Debug $create_table_query
  [System.Data.SQLite.SQLiteCommand]$sql_command = New-Object System.Data.SQLite.SQLiteCommand ($create_table_query,$connection)
  $sql_command.ExecuteNonQuery()
  $connection.Close()

}


function query_database_basic {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$query = 'SELECT CAPTION, URL, CODE FROM [destinations]'
  )

  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  $datatSet = New-Object System.Data.DataSet

  $dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter ($query,$connection)
  [void]$dataAdapter.Fill($datatSet)
  $connection.Close()
  return $datatSet.Tables[0].Rows
}


function query_database {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$query = 'SELECT URL, CAPTION, CODE  FROM destinations WHERE CAPTION = ?',
    [string]$destination = 'Ensenada',
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null),
    [System.Management.Automation.PSReference]$fields_ref = ([ref]@()),
    [bool]$debug
  )

  [object]$fields = @()
  if ($fields_ref -ne $null) {
    try {
      $fields_ref.Value | ForEach-Object {
        $fields += $_
      }
    } catch [exception]{}
  }

  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  [void]$connection.Open()
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $caption = New-Object System.Data.SQLite.SQLiteParameter
  [void]$command.Parameters.Add($caption)
  $caption.Value = $destination

  [System.Data.SQLite.SQLiteDataReader]$sql_reader = $command.ExecuteReader()
  try
  {
    Write-Debug 'Reading'
    while ($sql_reader.Read())
    {
      # Write-Debug ($sql_reader.GetString(0))
      # Write-Debug ($sql_reader.GetString(1))
      if ($fields.count -gt 0) {
        $local:result = @{}
        # # Write-Debug 'Ordinal'
        $iterator = 0..($fields.count - 1)
        $iterator | ForEach-Object {
          $cnt = $_
          $field = $fields[$cnt]
          # TODO: GetOrdinal does not work
          # $local:result += $sql_reader.GetOrdinal($field)
          # $data = $sql_reader.GetOrdinal($field)
          # $debug_msg = ('Ordinal({0}) = {1}' -f $field, $data)
          # Write-Debug $debug_msg
          $local:result[$field] = $sql_reader[$field]
        }
      } else {
        # Write-Debug 'Field'
        $local:result = @()
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
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$query = @"
UPDATE [destinations] SET URL = @url, STATUS = :status WHERE CODE = @code
-- can use @  or :   
"@,
    [psobject]$data
  )

  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  Write-Output $query
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $code = New-Object System.Data.SQLite.SQLiteParameter
  $caption = New-Object System.Data.SQLite.SQLiteParameter
  $url = New-Object System.Data.SQLite.SQLiteParameter
  $status = New-Object System.Data.SQLite.SQLiteParameter

  $parameter_1 = New-Object System.Data.SQLite.SQLiteParameter
  $parameter_1 | Get-Member
  $command.Parameters.Add($parameter_1)
  $parameter_1.Value = "xzzz"
  $parameter_1.ParameterName = "@code"

  $parameter_2 = New-Object System.Data.SQLite.SQLiteParameter
  $parameter_2 | Get-Member
  $command.Parameters.Add($parameter_2)
  $parameter_2.Value = "new url"
  $parameter_2.ParameterName = "@url"

  $parameter_3 = New-Object System.Data.SQLite.SQLiteParameter
  $parameter_3 | Get-Member
  $command.Parameters.Add($parameter_3)
  $parameter_3.Value = 0
  $parameter_3.ParameterName = "status"

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
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$query = @"
INSERT INTO [destinations] (CODE, CAPTION, URL, STATUS )  VALUES(?, ?, ?, ?)
"@,
    [psobject]$data
  )


  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
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


[string]$database = "$(Get-ScriptDirectory)\shore_ex.db"

$DebugPreference = 'Continue'
# NOTE: need to be careful when passing  -fields @()

query_database -Destination $destination -result_ref ([ref]$result)
if ($DebugPreference -eq 'Continue') {
  Write-Output 'Result:'
  $result | Format-List
}

$base_url = $result[0]
Write-Output ('base_url: "{0}"' -f $base_url)

$fields = @( 'URL', 'CAPTION')
query_database -Destination $destination -result_ref ([ref]$result) -fields_ref ([ref]$fields)
if ($DebugPreference -eq 'Continue') {
  Write-Output 'Result:'
  $result | Format-List
}

$base_url = $result['URL']
Write-Output ('base_url: "{0}"' -f $base_url)

# TODO: 
query_database_basic -database $database


return
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
# https://www.connectionings.com/sqlite/
