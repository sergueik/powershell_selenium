# https://knutkj.wordpress.com/2012/04/29/how-to-render-a-razor-template-with-powershell/
# 
# This is a vanilla script to bootstrap code requird to invoke RazorEngine.
# it has some minor modifications compared to
# https://github.com/knutkj/misc/blob/master/PowerShell/Razor/Render-RazorTemplate.ps1
# it depends on System.Web.Razor.dll which is in the GAC already:


# from 
[string]$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

# SHARED_ASSEMBLIES_PATH environment overrides parameter, for Team City
if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

# Load assembly from the GAC 
[void][Reflection.Assembly]::LoadWithPartialName($assembly_name)

# check if the System.Web.Razor is already loaded
$assembly_name = 'System.Web.Razor'
$razorAssembly =
[appdomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -match "^${assembly_name}" }


if ($razorAssembly -eq $null) {
  [string[]]$shared_assemblies = @( 'System.Web.Razor.dll')

  pushd $shared_assemblies_path
  popd

  # example of using nuget packages
  $nuget_base_dir = $PWD
  $razorSearchPath = Join-Path `
     -Path $nuget_base_dir `
     -ChildPath packages\AspNetRazor.Core.*\lib\net40\System.Web.Razor.dll

  $razorPath = Get-ChildItem -Path $razorSearchPath |
  Select-Object -First 1 -ExpandProperty FullName

  if ($razorPath -ne $null) {
    Add-Type -Path $razorPath
  } else {
    throw "The System.Web.Razor assembly must be loaded."
  }
}

$razor_code_language = New-Object -TypeName 'System.Web.Razor.CSharpRazorCodeLanguage'
$razor_engine_host = New-Object
-TypeName 'System.Web.Razor.RazorEngineHost' -ArgumentList $razor_code_language -Property @{
  DefaultBaseClass = 'TemplateBase';
  DefaultClassName = 'Template';
  DefaultNamespace = 'Templates';
}
$razor_template_engine = New-Object -TypeName System.Web.Razor.RazorTemplateEngine -ArgumentList $razor_engine_host
