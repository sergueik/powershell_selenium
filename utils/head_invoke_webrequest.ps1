#
# based on question: http://www.cyberforum.ru/powershell/thread2562775.html
# see also: https://davidhamann.de/2019/04/12/powershell-invoke-webrequest-by-example/

# Powershell invoke-webrequest does not show the resource status as curl,
# because one has to specifically
# force invoke-webrequest to stop following redirects and also ignore the error:
# take care of
<#
  invoke-webrequest : The request was aborted: Could not create SSL/TLS secure channel.
#>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

[Net.ServicePointManager]::SecurityProtocol =
  [Net.SecurityProtocolType]::Tls12 -bor `
  [Net.SecurityProtocolType]::Tls11 -bor `
  [Net.SecurityProtocolType]::Tls

[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'
# origin: https://stackoverflow.com/questions/41618766/powershell-invoke-webrequest-fails-with-ssl-tls-secure-channel

$url = 'https://www.slimjet.com/chrome/download-chrome.php?file=files%2F78.0.3904.97%2FChromeStandaloneSetup.exe'

# converted the standar curl command
# curl -I -k $url 2>/dev/null
# NOTE: redirection does not work verbatim:

# c:/tools/curl.exe -I -k $url 2>nul
# Redirection to 'nul' failed: FileStream will not open Win32 devices such as disk partitions and tape drives.

c:/tools/curl.exe -I -k $url

<#
  HTTP/1.1 302 Moved Temporarily
  Date: Sat, 28 Dec 2019 23:21:30 GMT
  Server: Apache
  location: http://www.slimjetbrowser.com/chrome/files/78.0.3904.97/ChromeStandaloneSetup.exe
  Content-Type: text/html; charset=UTF-8
#>

$bad_head_request = invoke-webrequest -method Head -uri $url
$bad_head_request | select-object -expandproperty StatusCode

# 200
$bad_head_request | select-object -expandproperty Headers
<#
  Key             Value
  ---             -----
  Connection      keep-alive
  CF-Cache-Status HIT
  Age             121643
  CF-RAY          54c748771f6fba82-ATL
  Accept-Ranges   bytes
  Content-Length  58957736
  Cache-Control   max-age=86400
  Content-Type    application/x-msdownload
  Date            Sat, 28 Dec 2019 23:23:37 GMT
  Last-Modified   Tue, 12 Nov 2019 20:24:59 GMT
  Set-Cookie      __cfduid=df104e086629904897c1d9f70a5879f8c1577575417; expire...
  Server          cloudflare
#>
# NOTE: some URLs return stream
# $url = 'http://91.192.168.242:9091'

$head_request = invoke-webrequest -MaximumRedirection 0 -method Head -uri $url -erroraction silentlycontinue
$status_code = $head_request | select-object -expandproperty StatusCode
write-host $status_code
# 302

if ($status_code -eq '302' ) {
  $url = $head_request.Headers.Location;
  ($head_request.Headers).psobject.properties| foreach-object {
    # outputs multiple technical values of no interest
    write-host $_.Value
  }
  @('Content-Type','Date','Location','Server') | foreach-object {
    $header = $_;
    write-host ('{0}: {1}' -f $header, $head_request.Headers.$header )
  }
}

$head_request | select-object -expandproperty Headers | format-list
<#
  Key   : Content-Type
  Value : text/html; charset=UTF-8

  Key   : Date
  Value : Sat, 28 Dec 2019 23:28:36 GMT

  Key   : Location
  Value : http://www.slimjetbrowser.com/chrome/files/78.0.3904.97/ChromeStandalon
          eSetup.exe

  Key   : Server
  Value : Apache
#>

$redirect_location = 'https://www.slimjet.com/chrome/files/78.0.3904.97/ChromeStandaloneSetup.exe'
$redirect_location = $head_request.Headers.Location

$url = $redirect_location


$head_request = invoke-webrequest -MaximumRedirection 0 -method Head -uri $url -erroraction silentlycontinue
$status_code = $head_request | select-object -expandproperty StatusCode
write-host $status_code
# 302
$accept = ''
if ($status_code -eq '200' ) {
  $size =  $head_request.Headers.'Content-Length'
  write-host ('WARNING - about to start a {0} Mb download that would take a long time dependent on the connecton bandwidth' -f ([Math]::Round($size / 1048576,0)) )
  $accept = Read-Host -Prompt 'Type Y to accept'
}
if ($accept -ne 'Y' -and $accept -ne 'y') {
  exit 0
}
$outfile = 'result.data'

invoke-webrequest -uri $url -outfile $outfile -timeout 10


get-item -path $outfile  | select-object -property Attributes,Length,Name,DirectoryName,CreationTime,LastWriteTime,VersionInfo

<#
Attributes    : Archive
Length        : 58957736
Name          : result.data
DirectoryName : C:\Users\▒▒▒▒▒▒▒▒▒▒▒▒
CreationTime  : 12/29/2019 11:10:01 AM
LastWriteTime : 12/29/2019 11:11:27 AM

#>

exit 0


# the code below is  taken from the original foorum question.
# The code does not appear to really belong to the party asking for help, more likely is a
# stackoverflow paste, already seen in several topics
# it does not have code
# to run the url download on a separate thread

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Status Server'
$form.Size = New-Object System.Drawing.Size(350,500)
$form.BackColor = "0x7AC5E7"
$form.Opacity = 0.96
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::SizableToolWindow
$form.StartPosition = 'CenterScreen'

$outfile = New-TemporaryFile

$eventHandler = [System.EventHandler]{
$textBox.Text
$listbox.Items.Add
$url = $textBox.Text
[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'
$head_request = invoke-webrequest -MaximumRedirection 0 -method Head -timeout 10 -uri $url -erroraction silentlycontinue

# $outfile = ('{0}\{1}' -f $env:USERPROFILE, 'result.data')

$status_code = $head_request | select-object -expandproperty StatusCode
if ($status_code -eq '302' ) {
  $url = $head_request.Headers.Location
  @('Content-Type','Date','Location','Server') | foreach-object {
    $header = $_;
    write-host ('{0}: {1}' -f $header, $head_request.Headers.$header )
    [void]$listbox.Items.Add( ('{0}: {1}' -f $header, $head_request.Headers.$header ))
  }
}

invoke-webrequest -uri $url -outfile $outfile -timeout 10
# (Invoke-WebRequest -Uri $url).RawContent | Out-File $outfile.FullName
# Loading a 34 Mb file into a lostbox is not a good idea
#
# Get-Content $file.FullName | ForEach-Object {[Void]$listbox.Items.Add($_)}
$listbox.Items.Add(('Saved into "{0}"' -f $outfile.FullName) )
}

$eventHandler2 = [System.EventHandler]{
start-process -filepath 'C:\Windows\System32\notepad.exe' -argumentlist $file.FullName
Start-Sleep -Milliseconds 300
$form.Close()
}

$eventHandler3 = [System.EventHandler]{
$listBox.Items.Clear()
$textBox.Clear()
Remove-Item $file.FullName -errorAction silentlycontinue
}

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(10,420)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Anchor = "Top, Right"
$OKButton.Text = 'OK'
$OKButton.Add_Click($eventHandler)
$form.Controls.Add($OKButton)

$LButton = New-Object System.Windows.Forms.Button
$LButton.Location = New-Object System.Drawing.Point(170,420)
$LButton.Size = New-Object System.Drawing.Size(75,23)
$LButton.Anchor = "Top, Right"
$LButton.Text = 'Clear'
$LButton.Add_Click($eventHandler3)
$form.Controls.Add($LButton)

$NButton = New-Object System.Windows.Forms.Button
$NButton.Location = New-Object System.Drawing.Point(250,420)
$NButton.Size = New-Object System.Drawing.Size(75,23)
$NButton.Anchor = "Top, Right"
$NButton.Text = 'Notepad'
$NButton.Add_Click($eventHandler2)
$form.Controls.Add($NButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(90,420)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Anchor = "Top, Right"
$CancelButton.Text = 'Cancel'
$CancelButton.Add_click({$form.close()})
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)

$label.Text = 'url: '
# $label.Text = 'Вставьте ссылку:'
# Unexpected token 'ÑÑ‚Ð°Ð²ÑŒÑ‚Ðµ' in expression or statement.
$form.Controls.Add($label)

$textBox = New-Object "System.Windows.Forms.TextBox"
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(315,20)
$textBox.Anchor = 'Top, Left, Right'
$textBox.width = 315;
$form.Controls.Add($textBox)

$listbox = New-Object System.Windows.Forms.ListBox
$listbox.DisplayMember = $tmp.FullName
$listbox.Name = "listbox"
$listbox.Location = New-Object System.Drawing.Point(10,75)
$listbox.Size = New-Object System.Drawing.Size(315,330)
$listbox.Anchor = "Top, Bottom, Left, Right"
$listbox.Height = 330

$form.Controls.Add($listbox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$form.Add_Shown({$listbox.Select()})
$form.ShowDialog()
Remove-Item $file.FullName -errorAction silentlycontinue

exit 0

