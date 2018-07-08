param(
[int]$model_choice = 2
)
# https://knutkj.wordpress.com/2012/04/29/how-to-render-a-razor-template-with-powershell/
# https://github.com/dzharii/swd-recorder
# This is a vanilla script to bootstrap code requird to invoke RazorEngine.
# it has some minor modifications compared to
# https://github.com/knutkj/misc/blob/master/PowerShell/Razor/Render-RazorTemplate.ps1
# it depends on System.Web.Razor.dll which is already in the GAC, but not loaded by defauls, or can be restored by nuget:


$assembly_name = 'System.Web.Razor'

# Load assembly from the GAC 
[void][Reflection.Assembly]::LoadWithPartialName($assembly_name)

# check if the System.Web.Razor is already loaded
$assembly_in_the_GAC =
[appdomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -match "^${assembly_name}" }


if ($assembly_in_the_GAC -eq $null) {
  [string[]]$shared_assemblies = @( 'System.Web.Razor.dll')

  [string]$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'

  # SHARED_ASSEMBLIES_PATH environment overrides parameter, for Team City
  if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  }

  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    if ($host.Version.Major -gt 2) {
      Unblock-File -Path $_;
    }
    Write-Debug $_
    Add-Type -Path $_
  }

  popd

  # Example of finding assembly downloaded by nuget package restore

  $nuget_packages_base_path = $PWD
  $assembly_path = Join-Path -Path $nuget_packages_base_path -ChildPath "packages\AspNetRazor.Core.*\lib\net40\${assembly_name}.dll"

  $assembly_nuget_package_path = Get-ChildItem -Path $assembly_path | Select-Object -First 1 -ExpandProperty FullName

  if ($assembly_nuget_package_path -ne $null) {
    Add-Type -Path $assembly_nuget_package_path
  } else {
    throw ('The System.Web.Razor assembly cannot be found. Nothing was found in nuget package restore of "{0}"' -f $nuget_packages_base_path)
  }
}

$imports = @'

# SCRIPT PARAMETERS.
param(
  [string]$browser = 'firefox',
  [int]$browser_version,  # unused
  [switch]$grid, # unused
  [string]$base_url =  'https://github.com/dzharii/swd-recorder',
  [switch]$pause
)
# END OF PARAMETERS.

function launch_selenium {
  param(
    $browser = ''
  )
  $driver_folder_path = 'C:\java\selenium' 
  $shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'
  $shared_assemblies = @@(
    'WebDriver.dll',
    'WebDriver.Support.dll',
    'nunit.framework.dll'
  )

  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    if ($host.Version.Major -gt 2) {
      Unblock-File -Path $_
    }
    Write-Debug $_
    Add-Type -Path $_
  }
  popd
  # adding driver folder to the path environment
  if (-not (Test-Path $driver_folder_path))
  {
    throw "Folder ${driver_folder_path} does not Exist, cannot be added to $env:PATH"
  }
  # See if the new folder is already in the path.
  if ($env:PATH | Select-String -SimpleMatch $driver_folder_path)
  { Write-Debug "Folder ${driver_folder_path} already within `$env:PATH"

  }

  # Set the new PATH environment
  $env:PATH = $env:PATH + ';' + $driver_folder_path


  # launch browser
  switch ($browser)
  {
    'firefox' {


      $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver
    }
    'chrome' {
      $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver

      $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver
    }
    'ie' {


      $selenium = New-Object OpenQA.Selenium.IE.InternetExplorerDriver ($driver_folder_path)
    }
    default {
      Write-Host 'Running on phantomjs'
      $headless = $true
      $phantomjs_executable_folder = 'C:\tools\phantomjs-2.0.0\bin'
      $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
      $selenium.Capabilities.setCapability('ssl-protocol','any')
      $selenium.Capabilities.setCapability('ignore-ssl-errors',$true)
      $selenium.Capabilities.setCapability('takesScreenshot',$true)
      $selenium.Capabilities.setCapability('userAgent',$phantomjs_useragent)
      $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
      $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
    }

  }

  return $selenium
}


function find_element {
  param(
    [Parameter(ParameterSetName = 'set_xpath')] $xpath,
    [Parameter(ParameterSetName = 'set_css_selector')] $css,
    [Parameter(ParameterSetName = 'set_id')] $id,
    [Parameter(ParameterSetName = 'set_linktext')] $linktext,
    [Parameter(ParameterSetName = 'set_partial_link_text')] $partial_link_text,
    [Parameter(ParameterSetName = 'set_css_tagname')] $tagname
  )


  # guard
  $implemented_options = @@{
    'xpath' = $true;
    'css' = $true;
    'id' = $false;
    'linktext' = $false;
    'partial_link_text' = $false;
    'tagname' = $false;
  }

  $implemented.Keys | ForEach-Object { $option = $_
    if ($psBoundParameters.ContainsKey($option)) {

      if (-not $implemented_options[$option]) {

        Write-Output ('Option {0} i not implemented' -f $option)



      } else {

      }
    }
  }
  if ($false) {
    Write-Output @@psBoundParameters | Format-Table -AutoSize
  }
  $element = $null
  $wait_seconds = 5
  $wait_polling_interval = 50

  if ($css -ne $null) {

    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
    $wait.PollingInterval = $wait_polling_interval

    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css)))
    } catch [exception]{
      Write-Debug ("Exception : {0} ...`ncss = '{1}'" -f (($_.Exception.Message) -split "`n")[0],$css)
    }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css))


  }


  if ($xpath -ne $null) {

    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenum,[System.TimeSpan]::FromSeconds($wait_seconds))
    $wait.PollingInterval = $wait_polling_interval

    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
    } catch [exception]{
      Write-Debug ("Exception : {0} ...`nxpath={1}" -f (($_.Exception.Message) -split "`n")[0],$xpath)
    }

    $element = $local:selenum_driver.FindElement([OpenQA.Selenium.By]::XPath($xpath))


  }

  return $element
}

function highlight {
  param(
    [object]$element,
    [int]$delay = 300
  )
  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'color: yellow; border: 4px solid yellow;')
  Start-Sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')
}



function cleanup
{
  param(
    [object]$selenium
  )
  try {
    $selenium.Quit()
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
  }
}


$selenium = launch_selenium -browser 


[void]$selenium.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(10))
$selenium.Navigate().GoToUrl($base_url)


# [NUnit.Framework.Assert]::IsTrue(($element.Text -match $expected_text),('expected: {0} got:{1}' -f $expected_text,$element.Text))

# TEST CLEANUP
cleanup $selenium
# END OF THE TEST

'@

$functions = @'


@functions{

    string FindHow(string how)
    {
        switch (how)
        {
            case "Id":              return "id";
            case "Name":            return "name";
            case "ClassName":       return "class";
            case "CssSelector":     return "css_selector";
            case "LinkText":        return "text";
            case "PartialLinkText": return "text";
            case "XPath":           return "xpath";
            default:                return String.Format("!!! LOCATOR PARSE ERROR : '{0}' !!!", how);
        }
    }

    string QuoteLocator(string locator)
    {
        locator = locator.Replace("'", "\\'");
        return locator;
    }    


    string PowershellElementFindCommand(string name, string tag, string type, string how, string locator)
    {
        System.Text.StringBuilder result = new System.Text.StringBuilder();
        result.AppendFormat("${0} = find_element ", name);   
        result.AppendFormat("-{0} ", FindHow(how));   
        result.AppendFormat("'{0}'", QuoteLocator(locator));
        result.AppendFormat("\n<# tag = '{0}' type = '{1}' #>", tag, type);

        return result.ToString();
    }
}


'@
$base_url = 'https://github.com/dzharii/swd-recorder'
$models = @(
  @{
    'input' = '<ul>@foreach(var i in Model){<li>@i</li>}</ul>';
    [object]'model' = @( 0..3);
    'model_generator' = [scriptblock]{ @( 0..3) };

  },
  @{
    'input' = @"

@{

    <text>###</text>
    <text>@@Model.PageObject.Name = '@Model.PageObject.Name'</text>
    <text>@@Model.PageObject.HtmlTag = '@Model.PageObject.HtmlTag'</text> 
    <text>@@Model.PageObject.Type = '@Model.PageObject.Type'</text> 
    <text>@@Model.PageObject.How = '@Model.PageObject.How'</text>
    <text>@@Model.PageObject.Locator = '@Model.PageObject.Locator'</text>
    <text>@PowershellElementFindCommand(@Model.PageObject.Name, @Model.PageObject.HtmlTag, @Model.PageObject.Type, @Model.PageObject.How, @Model.PageObject.Locator)</text>
    <text>###
    </text>
}

"@;
    'model_generator' = [scriptblock]{

      $model = New-Object PSObject

      $element = New-Object PSObject
      $element | Add-Member Noteproperty 'Name' 'search_field'
      $element | Add-Member Noteproperty 'Type' 'ordered_list'
      $element | Add-Member Noteproperty 'How' 'XPath'
      $element | Add-Member Noteproperty 'HtmlTag' ''
      $element | Add-Member Noteproperty 'Locator' 'id("searchInput")'

      $model | Add-Member Noteproperty 'PageObject' $element
      return $model;
    }

  },
  @{
    'input' = @"

@foreach (var element in @Model.PageObject.Items ) 
{
      
    <text>###</text>
    <text>@@element.Name = '@element.Name'</text>
    <text>@@element.HtmlTag = '@element.HtmlTag'</text> 
    <text>@@element.Type = '@element.Type'</text> 
    <text>@@element.How = '@element.How'</text>
    <text>@@element.Locator = '@element.Locator'</text>
    <text>@PowershellElementFindCommand(@element.Name, @element.HtmlTag, @element.Type, @element.How, @element.Locator)</text>
    <text>### 
    </text>
}

"@;
    'model_generator' = [scriptblock]{

      $model = New-Object PSObject
      $how_choices = @('CssSelector', 'XPath', 'Id', 'LinkText' , 'ClassName')
      $items = @()

      (0..($how_choices.Count-1)) | ForEach-Object {

        $cnt = $_
        $element = New-Object PSObject
        $element | Add-Member Noteproperty 'Name' ('element_{0}' -f $cnt)
        $element | Add-Member Noteproperty 'Type' 'unused'
        $element | Add-Member Noteproperty 'How' $how_choices[$_]
        $element | Add-Member Noteproperty 'HtmlTag' ('element_html_tag_{0}' -f $cnt)
        $element | Add-Member Noteproperty 'Locator' ('div > :nth-of-type({0})' -f $cnt)
        $element | Add-Member Noteproperty 'Xpath' 'id("js-repo-pjax-container")/div[1]/table[1]/tbody[1]/tr[1]/td[1]/span[1]/a[1]'
        $element | Add-Member Noteproperty 'CssSelector' 'div[id = "js-repo-pjax-container"] > div:nth-of-type(6) > table > tbody > tr:nth-of-type(9) > td:nth-of-type(3) > span > a' 

        $items += $element
      }
      $pageobject = New-Object PSObject
      $pageobject | Add-Member Noteproperty 'Items' $items

      $model | Add-Member Noteproperty 'PageObject' $pageobject
      return $model
    }

  }
)


$input = $models[$model_choice].input
$model = Invoke-Command $models[$model_choice].model_generator

$template = @( $imports,$functions,$input) -join "`r`n"

$modelType = 'dynamic'
$template_class_name = ('t_{0}' -f (Get-Random -Maximum 5000))
$template_baseclass_name = ('t_{0}' -f (Get-Random -Maximum 5000))
$template_namespace = 'razor.templates'

# generate unique template base class
$template_base_class = @"

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Microsoft.CSharp.RuntimeBinder;

namespace {2} {{

    public abstract class {1}
    {{
        protected {0} Model;
        private StringBuilder _sb = new StringBuilder();
        public abstract void Execute();
        public virtual void Write(object value)
        {{
            WriteLiteral(value);
        }}
        public virtual void WriteLiteral(object value)
        {{
            _sb.Append(value);
        }}
        public string Render ({0} model)
        {{
            Model = model;
            Execute();
            var res = _sb.ToString();
            _sb.Clear();
            return res;
        }}
    }}
}}
"@ -f $modelType,$template_baseclass_name,$template_namespace

# instantiate a razor template
[System.Web.Razor.CSharpRazorCodeLanguage]$razor_code_language = New-Object System.Web.Razor.CSharpRazorCodeLanguage
$razor_engine_host = New-Object -TypeName 'System.Web.Razor.RazorEngineHost' -ArgumentList $razor_code_language -Property @{
  DefaultBaseClass = ('{0}.{1}' -f $template_namespace,$template_baseclass_name);
  DefaultClassName = $template_class_name;
  DefaultNamespace = $template_namespace;
}
$razor_template_engine = New-Object System.Web.Razor.RazorTemplateEngine ($razor_engine_host)

$sr = New-Object System.IO.StringReader ($template)
$code = $razor_template_engine.GenerateCode($sr)

# do template compilation
[System.IO.StringWriter]$sw = New-Object System.IO.StringWriter
[Microsoft.CSharp.CSharpCodeProvider]$compiler = New-Object Microsoft.CSharp.CSharpCodeProvider
[void]$compiler.GenerateCodeFromCompileUnit($code.GeneratedCode,$sw,$null)

# do template execution
Add-Type -TypeDefinition ($template_base_class + "`n" + $sw.ToString()) -ReferencedAssemblies 'System.Core','Microsoft.CSharp'

$instance = New-Object -TypeName ('{0}.{1}' -f $template_namespace,$template_class_name)

$instance.Render($model)
