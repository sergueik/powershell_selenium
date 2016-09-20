# origin : https://github.com/perplexityjeff/PowerShell-InternetExplorer-TrustedZone
function Add-IETrustedWebsite ([string]$website) 
{
    #Declares
    $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\'
    $pathCreate = $path + $website

    #Check if the registry key already exists
    $pathExists = Test-Path $pathCreate
    if (!$pathExists)
    {
        #Create new entry
        New-Item -Path $pathCreate

        #Create new registry values for http and https to add it to the Trusted Zone
        New-ItemProperty -Path $pathCreate -Name "http" -Value "2" -PropertyType 'DWORD' -Force | Out-Null
        New-ItemProperty -Path $pathCreate -Name "https" -Value "2" -PropertyType 'DWORD' -Force | Out-Null
    }
}