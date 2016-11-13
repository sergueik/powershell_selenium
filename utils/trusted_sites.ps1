# based on : https://github.com/perplexityjeff/PowerShell-InternetExplorer-TrustedZone
function Add-IETrustedWebsite {
  param(
    [string]$website
  )
  $website_path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\' + $website

  if (-not (Test-Path $website_path -ErrorAction SilentlyContinue)) {
    New-Item -Path $website_path
    # Create rules for http and https to add it to the Trusted Zone
    foreach ($protocol in @( 'http','https')) {
      New-ItemProperty -Path $website_path -Name $protocol -Value '2' -PropertyType 'DWORD' -Force | Out-Null
    }
  }
}

function Remove-IETrustedWebsite {
  param(
    [string]$website
  )
  $website_path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\' + $website
  if (Test-Path $website_path) {
    Remove-Item -Path $website_path -Recurse
  }
}