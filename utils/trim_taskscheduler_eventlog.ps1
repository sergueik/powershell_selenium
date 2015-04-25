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
# $DebugPreference = 'Continue'

param(
  [int]$new_size = 1179648 # will be read as 1152 K
)
$channel_name = 'Microsoft-Windows-TaskScheduler/Operational'
Write-Host -ForegroundColor 'green' (@"
This sets the size of the eventlog file for "{0}" 
"@ -f $channel_name)


$update_settings = @(

  @{
    'name' = 'MaxSize';
    'value' = $new_size;
  },
  @{ 'name' = 'Enabled'
    'value' = 1;
  }
)
$hive = 'HKLM:'
$path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/WINEVT/Channels'

$update_settings | ForEach-Object {
  $row = $_
  $name = $row['name']
  $new_value = $row['value']
  pushd $hive
  cd $path
  cd $channel_name
  $current_value = Get-ItemProperty -Path ('{0}/{1}/{2}' -f $hive,$path,$channel_name) -Name $name -ErrorAction 'SilentlyContinue'
  if ($current_value -eq $null) {
    $current_value = 0
  } else {
    $current_value = $current_value."$name" }

  Write-Output ('Current value "{1}" =  "{0}"' -f $name, $current_value)

  if ($current_value -ne $new_value) {
    Set-ItemProperty -Path ('{0}/{1}/{2}' -f $hive,$path,$channel_name) -Name $name -Value $new_value
  }
  popd
}

