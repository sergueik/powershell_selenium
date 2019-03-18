$downloadToPath = 'c:\temp\file.html'
$remoteFileLocation = 'http://bandi.servizi.politicheagricole.it/taxcredit/Menu.aspx'

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

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
  # NOTE: we do not even parsethe epory in the cookie,
  # luckily since it is null
  $cookie.Secure =  ($false -or $cookie_item.'secure')

  $session.Cookies.Add($cookie);
}

Invoke-WebRequest $remoteFileLocation -WebSession $session -TimeoutSec 900 -OutFile $downloadToPath

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

# response is in c:\temp\file.html
# it looks like it i /default.aspx:
#     Normativa
#    Manuale utente#
#
# Sei già registrato?
#
# ACCEDI
# A C C E D I
# Registrati adesso
