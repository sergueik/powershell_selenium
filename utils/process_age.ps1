#Copyright (c) 2020 Serguei Kouzmine
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


# based on: https://www.cyberforum.ru/powershell/thread2649209.html

# says the Powershell cmdlet
# get-process -IncludeUserName
# requires privilege elevation
param(
  [String]$name = 'chromedriver.exe', # TODO:  support list to be able to prune consolehost.exe but keep one's own host
  [switch]$debug,
  [Int]$minutes = 30
)

[bool]$_debug = [bool]$PSBoundParameters['debug'].IsPresent
if ($_debug) {
  write-output ('name = {0}' -f $name)
  write-output ('minutes = {0}' -f $minutes)
}
$rows = tasklist.exe /FI "USERNAME eq $Env:UserName" /FI "IMAGENAME eq ${name}" /FO csv | ConvertFrom-Csv
if ($_debug) {
  $rows | format-list
}
$result = @()
if ($_debug) {
  # on Windows platform the conhost.exe and chromedriver.exe are unrelated
  foreach ($row in $rows) {
    $id = $row.Pid
    if ($_debug) {
      write-output ('Inspecting pid {0}' -f $id)
      get-CimInstance Win32_Process -Filter "ParentProcessId = ${id}"
    }
    # home-brewed alternative to `if`
    get-process -id $id -ErrorAction 'SilentlyContinue' | where-object {
      ($(get-date) - $($_.StartTime)).TotalMinutes -gt $minutes
    } | forEach-object {
       $id
    }
  }
}
$result = foreach ($row in $rows) {
  # NOTE: in Powershell pid is a special variable
  # cannot overwrite variable PID because it "is read-only or constant"
  $id = $row.Pid
  # home-brewed alternative to `if`
  get-process -id $id -ErrorAction 'SilentlyContinue' | where-object {
    ($(get-date) - $($_.StartTime)).TotalMinutes -gt $minutes
  } | forEach-object {
     $id
  }
}
if (-not $_debug) {
  $result | foreach-object {
    $id = $_
    taskkill.exe /pid $id /F /T |out-null
  }
}
