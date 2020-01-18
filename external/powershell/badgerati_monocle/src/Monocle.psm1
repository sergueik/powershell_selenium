$ProgressPreference = 'SilentlyContinue'

# root path to module
$root = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
$root = 'C:\developer\sergueik\powershell_selenium\external\powershell\xxx\Monocle\src'
# get the path to the drivers and load them
# $libraries = Join-Path $root 'lib'
$libraries = 'C:\developer\sergueik\powershell_selenium\external\powershell\xxx\Monocle\src\lib'
# $path = Join-Path $libraries 'WebDriver'
$_path = "C:\developer\sergueik\powershell_selenium\external\powershell\xxx\Monocle\src\lib\WebDriver"

switch ($PSEdition.ToLowerInvariant()) {
    'core' {
        $_path = Join-Path $_path 'netstandard2.0'
    }

    default {
        $_path = Join-Path $_path 'net45'
    }
}

Get-ChildItem -Path "C:\developer\sergueik\powershell_selenium\external\powershell\xxx\Monocle\src\lib\WebDriver\net45" -Filter '*.dll' -File -Force | ForEach-Object {
    Add-Type -Path $_.FullName | Out-Null
}

# load private functions
Get-ChildItem "$($root)/Private/*.ps1" | Resolve-Path | ForEach-Object { . $_ }

# get current functions to import public functions
$sysfuncs = Get-ChildItem Function:

# load public functions
Get-ChildItem "$($root)/Public/*.ps1" | Resolve-Path | ForEach-Object { . $_ }

# get functions from memory and compare to existing to find new functions added
$funcs = Get-ChildItem Function: | Where-Object { $sysfuncs -notcontains $_ }

# export the module's public functions
Export-ModuleMember -Function ($funcs.Name)
