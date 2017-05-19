# based on: https://github.com/majkinetor/posh/blob/master/MM_Network/Update-Proxy.ps1
#requires -version 2.0

<#
.SYNOPSIS
    Get or set system proxy properties.

.DESCRIPTION
    This function implements unified method to set proxy system wide settings.
    It sets both WinINET ("Internet Options" proxy) and WinHTTP proxy.
    Without any arguments function will return the current proxy properties.
    To change a proxy property pass adequate argument to the function.

.EXAMPLE
    Update-Proxy -Server "myproxy.mydomain.com:8080" -Override "" -ShowGUI

    Set proxy server, clear overrides and show IE GUI.

.EXAMPLE
    Update-Proxy | Export-CSV proxy;  Import-CSV proxy | Update-Proxy -Verbose

    Save and restore proxy properties

.EXAMPLE
    $p = Update-Proxy; $p.Override += $p.Override += "*.domain.com" ; $p | proxy

    Add "*.domain.com" to the proxy override list

.NOTES
    The format of the parameters is the same as seen in Internet Options GUI.
    To bypass proxy for a local network specify keyword ";<local>" at the end
    of the Overide values.
    Setting the winhttp proxy requires administrative prvilegies.

.OUTPUTS
    [HashTable]
#>
function Update-Proxy () {
  [CmdletBinding()]
  param(
    # Proxy:Port
    [Parameter(ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [string]$Server,
    # Semicollon delimited list of exlusions
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$Override,
    # 0 to disable, anything else to enable proxy
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$Enable,
    [switch]$ShowGUI
  )
  $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
  Write-Verbose 'Reading proxy data from the registry'
  $r = Get-ItemProperty $key
  $proxy = @{
    Server = if ($PSBoundParameters.Keys -contains 'Server') { $Server } else { $r.ProxyServer }
    Override = if ($PSBoundParameters.Keys -contains 'Override') { $Override } else { $r.ProxyOverride }
    Enable = if ($PSBoundParameters.Keys -contains 'Enable') { $Enable } else { $r.ProxyEnable }
  }

  [boolean]$changing_settings = 'Server','Override','Enable' | Where-Object { $PSBoundParameters.Keys -contains $_ }
  if ($changing_settings) {

    # Check to see if we are currently running "as Administrator" and if not relaunch as administrator
    $myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal ([System.Security.Principal.WindowsIdentity]::GetCurrent())
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    if ($myWindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {

      Write-Output 'Relaunch'
      # http://blogs.msdn.com/b/virtual_pc_guy/archive/2010/09/23/a-self-elevating-powershell-script.aspx
      # https://github.com/sergueik/powershell_ui_samples/blob/master/external/elevation_relaunch.ps1
      # Create a new process object that starts PowerShell
      $newProcess = New-Object System.Diagnostics.ProcessStartInfo 'PowerShell'
      # Specify the current script path and name as a parameter
      $newProcess.Arguments = $myInvocation.MyCommand.Definition
      # Indicate that the process should be elevated
      $newProcess.Verb = 'runas'
      # Start the new process
      # TODO: pass arguments
      [System.Diagnostics.Process]::Start($newProcess)
      # Exit from the current, unelevated, process
      exit
    }
    Write-Verbose 'Saving proxy data to registry'

    Set-ItemProperty -Path $key -Name 'ProxyServer' -Value $proxy.Server
    Set-ItemProperty -Path $key -Name 'ProxyOverride' -Value $proxy.Override
    Set-ItemProperty -Path $key -Name 'ProxyEnable' -Value $proxy.Enable
    if (!(refresh-system)) { Write-Warning 'Can not perform system refresh after proxy change' }

    Write-Verbose 'Importing winhttp proxy from IE settings'
    $OFS = "`n"
    [string]$res = netsh.exe winhttp import proxy source=ie
    if ($res -match 'Access is denied') { Write-Warning $res }
    else { Write-Verbose $res.Trim() }
  }

  New-Object PSCustomObject -Property $proxy
  if ($ShowGUI) { start control 'inetcpl.cpl,,4' }
}

# The registry changes aren't seen until system is notified about it.
# Without this function you need to open Internet Settings window for changes to take effect. See http://goo.gl/OIQ4W4
function refresh-system () {
  $signature = @'
[DllImport("wininet.dll", SetLastError = true, CharSet=CharSet.Auto)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
'@

  $type = Add-Type -MemberDefinition $signature -Name wininet -Namespace pinvoke -Passthru
  $INTERNET_OPTION_SETTINGS_CHANGED = 39
  $INTERNET_OPTION_REFRESH = 37
  $a = $type::InternetSetOption(0,$INTERNET_OPTION_SETTINGS_CHANGED,0,0)
  $b = $type::InternetSetOption(0,$INTERNET_OPTION_REFRESH,0,0)
  return $a -and $b
}
