# 

# http://stackoverflow.com/questions/570117/why-is-reflectiononlyassemblyresolve-not-executed-when-trying-to-assembly-reflec


[string]$fileToLoad = 'C:\temp\mstest\WebDriverFramework.dll';

[System.Reflection.AssemblyName ]$assamblyName = [System.Reflection.AssemblyName]::GetAssemblyName($fileToLoad);
# [System.Reflection.Assembly]::Load($assamblyName)
# [System.Reflection.Assembly]::LoadWithPartialName( $fileToLoad )
# [System.Reflection.Assembly]::ReflectionOnlyLoadFrom($fileToLoad )
<#
 Exception calling "LoadWithPartialName" with "1" argument(s): 
"The given assembly name or codebase was invalid. (Exception from HRESULT: 0x80131047)"
 #>

$testSuite = [System.Reflection.Assembly]::ReflectionOnlyLoadFrom("${assembly_path}\CarnivalTestScripts.dll")

$assembly_path = 'C:\temp\mstest'
$assemblies = @( 'WebDriverFramework.dll',
  'CarnivalUS.Core.dll',
  'CarnivalUK.Core.dll',
  'CarnivalMobile.Core.dll',
  'CarnivalTestScripts.dll'
)

$assemblies | ForEach-Object { [void][System.Reflection.Assembly]::ReflectionOnlyLoadFrom(('{0}\{1}' -f $assembly_path,$_)) }

try {
  $types = $testSuite.GetTypes()
  $types | Format-List | Out-Null
}
catch [System.Reflection.ReflectionTypeLoadException]{

  Write-Output $_.Exception.GetType().FullName;
  Write-Output $_.Exception.Message
  $_.Exception.LoaderExceptions | ForEach-Object { Write-Output $_ }
  <# 

  Cannot resolve dependency to assembly 'WebDriverFramework, Version=0.0.16.0,
  Culture=neutral, PublicKeyToken=null' because it has not been preloaded. When
  using the ReflectionOnly APIs, dependent assemblies must be pre-loaded or
  loaded on demand through the ReflectionOnlyAssemblyResolve event.
#>

}

$methods = $testSuite.GetTypes().GetMethods()
$methods | Select-Object -First 3 | Get-Member

$methods | Select-Object -First 3 | ForEach-Object { $_.GetCustomAttributes }
return
<#

$testMethods = $methods | 
    Where { 
        $_.GetCustomAttributesData() | 
            Where { $_.AttributeType.FullName -like "*.TestAttribute" } 
    }
$testDocumentation = $testMethods | 
    Select DeclaringType, Name, @{
        Name = "Description"
        Expression = { 
            $descriptionAttribute = $_.GetCustomAttributesData() |
                Where { $_.AttributeType.FullName -like "*.DescriptionAttribute"}
            Write-Output $descriptionAttribute.ConstructorArguments[0].Value
        }
    }
#>
