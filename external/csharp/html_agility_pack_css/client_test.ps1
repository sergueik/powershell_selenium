#Copyright (c) 2019 Serguei Kouzmine
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


# will pick an older downlevel to prevent framework dependency waterfall
$version = '1.7.0'
$version = '1.4.9'

$download_base_url = 'https://www.nuget.org/packages/HtmlAgilityPack/'

$download_base_url = 'https://www.nuget.org/packages/HtmlAgilityPack.CssSelector.Core/'

$version = '1.0.1'


# http://poshcode.org/2887
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
# https://msdn.microsoft.com/en-us/library/system.management.automation.invocationinfo.pscommandpath%28v=vs.85%29.aspx
# https://gist.github.com/glombard/1ae65c7c6dfd0a19848c
function Get-ScriptDirectory
{
  [string]$scriptDirectory = $null

  if ($host.Version.Major -gt 2) {
    $scriptDirectory = (Get-Variable PSScriptRoot).Value
    Write-Debug ('$PSScriptRoot: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
    Write-Debug ('$MyInvocation.PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    Write-Debug ('$PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
  } else {
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSScriptRoot) {
      $scriptDirectory = $Invocation.PSScriptRoot
    } elseif ($Invocation.MyCommand.Path) {
      $scriptDirectory = Split-Path $Invocation.MyCommand.Path
    } else {
      $scriptDirectory = $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))
    }
    return $scriptDirectory
  }
}

function load_shared_assemblies {
  param(
    [String]$shared_assemblies_path = "${env:USERPROFILE}\Downloads",
    [string[]]$shared_assemblies = @(
     # 'nunit.core.dll',
      'nunit.framework.dll'
    )
  )

  Write-Debug ('Loading "{0}" from ' -f ($shared_assemblies -join ',' ), $shared_assemblies_path)
  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    $shared_assembly_filename = $_
    if ( assembly_is_loaded -assembly_path ("${shared_assemblies_path}\\{0}" -f $shared_assembly_filename)) {
      write-debug ('Skipping from  assembly "{0}"' -f $shared_assembly_filename)
     } else {
      write-debug ('Loading assembly "{0}" ' -f $shared_assembly_filename)
      Unblock-File -Path $shared_assembly_filename;
      Add-Type -Path $shared_assembly_filename
    }
  }
  popd
}


# based on https://github.com/PowerShellCrack/AdminRunasMenu/blob/master/App/AdminMenu.ps1
# dealing with cache:
# inspect if the assembly is already loaded:

function assembly_is_loaded{
  param(
    [string[]]$defined_type_names = @(),
    [string]$assembly_path
  )

  $loaded_project_specific_assemblies = @()
  $loaded_defined_type_names = @()

  if ($defined_type_names.count -ne 0) {
    $loaded_defined_type_names = [appdomain]::currentdomain.getassemblies() |
        where-object {$_.location -eq ''} |
        select-object -expandproperty DefinedTypes |
        select-object -property Name
    # TODO: return if any of the types from Add-type is already there
    return ($loaded_defined_type_names -contains $defined_type_names[0])
  }

  if ($assembly_path -ne $null) {
    [string]$check_assembly_path = ($assembly_path -replace '\\\\' , '/' ) -replace '/', '\'
    # NOTE: the location property may both be $null or an empty string
    $loaded_project_specific_assemblies =
    [appdomain]::currentdomain.getassemblies() |
      where-object {$_.GlobalAssemblyCache -eq $false -and $_.Location -match '\S' } |
      select-object -expandproperty Location
      # write-debug ('Check if loaded: {0} {1}' -f $check_assembly_path,$assembly_path)
    write-debug ("Loaded asseblies:  {0}" -f $loaded_project_specific_assemblies.count)
    if ($DebugPreference -eq 'Continue') {
     if (($loaded_project_specific_assemblies -contains $check_assembly_path)) {
        write-debug ('Already loaded: {0}' -f $assembly_path)
      } else {
        write-debug ('Not loaded: {0}' -f $assembly_path)
      }
    }
    return ($loaded_project_specific_assemblies -contains $assembly_path)
  }
}


[String[]]$shared_assemblies = @(
  'HtmlAgilityPack.dll',
  # 'nunit.core.dll',
  'Newtonsoft.Json.dll',
  'nunit.framework.dll'
)
[String]$shared_assemblies_path = "${env:USERPROFILE}\Downloads"

# SHARED_ASSEMBLIES_PATH environment overrides parameter, for Team City/Jenkinks
if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

load_shared_assemblies -shared_assemblies_path $shared_assemblies_path -shared_assemblies $shared_assemblies

$doc = new-object -typeName 'HtmlAgilityPack.HtmlDocument'
$doc.LoadHtml(@'
<?xml version="1.0"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
  <head>
    <meta charset="utf-8"/>
    <title/>
  </head>
  <body>
    <div id="myDiv" first="1">
      <span id="spanA" class="cls-a clsb" enabled>SPAN1</span>
    </div>
    <br>
    <div id="myDiv">
      <p>P1</p>
    </div>
    <div>
      <span>s</span>
      <span id="spanB" class="cls-b c2 underscore_class">
        <p class="cls">P2</p>
      </span>
      <span class="cls c3">
        <p class="cls">P3</p>
      </span>
    </div>
  </body>
</html>
'@
)

@(
'//body/div[1]/span[@id="spanA"]',
'//body/div[1]/span[contains(@class, "clsb")]'
) | foreach-object {
  $xpath = $_
  $body = $doc.DocumentNode.SelectSingleNode($xpath)
  [NUnit.Framework.Assert]::NotNull($body)
  # Unexpected token 'typeof' in expression or statement. it has to be done somehow differently
  # [NUnit.Framework.Assert]::IsInstanceOf(typeof(HtmlAgilityPack.HtmlNode), $body, 'Expect strongly typed response')
  [NUnit.Framework.Assert]::IsInstanceOf([HtmlAgilityPack.HtmlNode], $body, 'Strongly typed response expected')
  [NUnit.Framework.Assert]::NotNull($body.OuterHtml)
  write-output ("XPath:`n{0}`nResult:`n{1}" -f $xpath, $body.OuterHtml.ToString())
}

$doc = $null
