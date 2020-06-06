# bsed on: https://www.cyberforum.ru/powershell/thread2649209.html

# says the Powershell cmdlet requires privilege elevation
# get-process -IncludeUserName
$name = 'chromedriver.exe'
$minutes = 30
$rows = tasklist.exe /FI "USERNAME eq $Env:UserName" /FI "IMAGENAME eq ${name}" /FO csv | ConvertFrom-Csv
$result = @()

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
$result | foreach-object { 
  $id = $_
  taskkill.exe /pid $id /F /T |out-null
}
