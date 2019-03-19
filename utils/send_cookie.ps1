$out_file = 'c:\temp\file.html'

# based on: https://blog.gripdev.xyz/2015/05/27/powershell-invoke-webrequest-with-a-cookie/
# see also: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-5.1#examples
# slightly different format: https://gist.github.com/JohnRoos/f5f40bf8bbef4020b165d4ecff142ffc
# see also: https://www.adamtheautomator.com/invoke-webrequest-powershell/
# http://blog.roostech.se/2017/02/invoke-restmethod-with-anti-forgery.html

$url = 'http://bandi.servizi.politicheagricole.it/taxcredit/Menu.aspx'
$url = 'http://bandi.servizi.politicheagricole.it/taxcredit/moduloTCR.aspx'
$debug  = $true
$session = new-object Microsoft.PowerShell.Commands.WebRequestSession

$cookie_data =  convertfrom-json -inputobject ((get-content (resolve-path 'cookies.json') ) -join '')

$cookie_data | foreach-object {
  $cookie = New-Object System.Net.Cookie

  $ExpiryDate =   Get-Date
  $ExpiryDate.AddDays(7)
  $cookie_item = $_
  $cookie.Name = $cookie_item.'name'
  $cookie.Value = $cookie_item.'value'
  $cookie.Domain = $cookie_item.'domain'
  $cookie.Path = $cookie_item.'path'
  $cookie.HttpOnly = ($false -or $cookie_item.'httpOnly')
  $cookie.Expires  = $ExpiryDate
  # NOTE: we do not even parse the expiry field from the cookie,
  # luckily since it is null
  $cookie.Secure = ($false -or $cookie_item.'secure')

  if ($debug){
    $cookie| format-list
  }
  $session.Cookies.Add($cookie);
}

invoke-webrequest -Method POST $url -WebSession $session -TimeoutSec 900 -OutFile $out_file

<#
# {"path":"/","domain":"bandi.servizi.politicheagricole.it","name":"ASP.NET_SessionId","httpOnly":true,"expiry":null,"secure":false,"value":"xxxxxxxxxxxxxxxxxxxxxxxx"},

$cookie = New-Object System.Net.Cookie

$cookie.Name = 'ASP.NET_SessionId'
$cookie.Value = '0dux3mgwelox2gru1jt5mqgu'
$cookie.Domain = 'bandi.servizi.politicheagricole.it'
$cookie.Path = '/'
$cookie.HttpOnly = $true
$cookie.Expires  =   $ExpiryDate
$cookie.Secure = $false

$session.Cookies.Add($cookie);
#>

<#

# {"path":"/","domain":".bandi.servizi.politicheagricole.it","name":"ARRAffinity","httpOnly":true,"expiry":null,"secure":false,"value":"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}

$cookie = New-Object System.Net.Cookie

$cookie.Name = 'ARRAffinity'
$cookie.Value = '8baa90639b969d8df14774e1cd0fcbcad641ade960f94a7cc7176ee0ed99cc80'
$cookie.Domain = 'bandi.servizi.politicheagricole.it'
$cookie.Path = '/'
$cookie.HttpOnly = $true
$cookie.Expires  =   $ExpiryDate
$cookie.Secure = $false

$session.Cookies.Add($cookie);
#>

# response looks like it i /default.aspx:
#     Normativa
#    Manuale utente#
#
# Sei già registrato?
#
# ACCEDI
# A C C E D I
# Registrati adesso
