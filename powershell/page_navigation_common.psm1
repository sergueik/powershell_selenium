<#
.SYNOPSIS
	Determines script directory
.DESCRIPTION
	Determines script directory

.EXAMPLE
	$script_directory = Get-ScriptDirectory

.LINK
	# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed

.NOTES
	TODO: http://joseoncode.com/2011/11/24/sharing-powershell-modules-easily/
	VERSION HISTORY
	2015/06/07 Initial Version
#>
# use $debugpreference = 'continue'/'silentlycontinue' to show / hide debugging information

# http://poshcode.org/2887
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
# https://msdn.microsoft.com/en-us/library/system.management.automation.invocationinfo.pscommandpath%28v=vs.85%29.aspx
# https://gist.github.com/glombard/1ae65c7c6dfd0a19848c

function Get-ScriptDirectory {

  if ($global:scriptDirectory -eq $null) {
    [string]$global:scriptDirectory = $null

    if ($host.Version.Major -gt 2) {
      $global:scriptDirectory = (Get-Variable PSScriptRoot).Value
      write-debug ('$PSScriptRoot: {0}' -f $global:scriptDirectory)
      if ($global:scriptDirectory -ne $null) {
        return $global:scriptDirectory;
      }
      $global:scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
      write-debug ('$MyInvocation.PSCommandPath: {0}' -f $global:scriptDirectory)
      if ($global:scriptDirectory -ne $null) {
        return $global:scriptDirectory;
      }

      $global:scriptDirectory = Split-Path -Parent $PSCommandPath
      write-debug ('$PSCommandPath: {0}' -f $global:scriptDirectory)
      if ($global:scriptDirectory -ne $null) {
        return $global:scriptDirectory;
      }
    } else {
      $global:scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
      if ($global:scriptDirectory -ne $null) {
        return $global:scriptDirectory;
      }
      $Invocation = (Get-Variable MyInvocation -Scope 1).Value
      if ($Invocation.PSScriptRoot) {
        $global:scriptDirectory = $Invocation.PSScriptRoot
      } elseif ($Invocation.MyCommand.Path) {
        $global:scriptDirectory = Split-Path $Invocation.MyCommand.Path
      } else {
        $global:scriptDirectory = $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))
      }
      return $global:scriptDirectory
    }
  } else {
      write-debug ('Returned cached value: `$global:scriptDirectory = "{0}"' -f $global:scriptDirectory)
      return $global:scriptDirectory
  }
}


<#
.SYNOPSIS
  Returns the content of the script file from to the provided filename as text
.DESCRIPTION
  Loads the javascript code from the provided path - looks in current directory then in each of $shared_scripts_paths

.EXAMPLE
  $highlightScript = loadScript 'highlight.js'

.LINK

.NOTES
  VERSION HISTORY
  2019/05/15 Initial Version
#>

function loadScript {
  param(
    [string]$scriptName = $null,
    [int]$version,
    [string[]]$shared_scripts_paths = @( 'c:\java\selenium\csharp\sharedassemblies'),
    [switch]$debug
  )
  if ($scriptName -eq $null) {
    throw [System.IO.FileNotFoundException] 'Script name can not be null.'
  }
  [string]$local:scriptDirectory = Get-ScriptDirectory
  [string]$local:scriptdata = $null
  write-debug ('Loading script "{0}"' -f $scriptName)

  $local:scriptPath = ("{0}\{1}" -f $local:scriptDirectory, $scriptName)
  if ( test-path -path $local:scriptPath){
    write-debug ('Found script in "{0}"' -f $local:scriptPath)
    $local:scriptdata = [IO.File]::ReadAllText($local:scriptPath)
  } else {
    foreach ($local:scriptDirectory in $shared_scripts_paths) {
      $local:scriptPath = ("{0}\{1}" -f $local:scriptDirectory, $scriptName)
      if ( test-path -path $local:scriptPath) {
        write-debug ('Found script in "{0}"' -f $local:scriptPath)
        $local:scriptdata = [IO.File]::ReadAllText($local:scriptPat)
      }
    }
  }
  write-debug ('Loaded "{0}"' -f $local:scriptdata)
  if ($local:scriptdata -eq $null -or $local:scriptdata -eq '' ) {
    throw [System.IO.FileNotFoundException] "Script file ${scriptName} was not be found or is empty."
  }
  return $local:scriptdata
}


<#
.SYNOPSIS
  Returns the Xpath to the provided Selenium page element
.DESCRIPTION
  Runs the javascript code through Selenium and returns the Xpath path to the provided Selenium page element

.EXAMPLE
  $javascript_generated_xpath_to_element = xpathOfElement ([ref] $element)

.LINK
  # https://chromium.googlesource.com/chromium/blink/+/master/Source/devtools/front_end/components/DOMPresentationUtils.js

.NOTES
  VERSION HISTORY
  2015/07/03 Initial Version
#>

function xpathOfElement {
  param(
    [System.Management.Automation.PSReference]$element_ref
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:rawjson = $null

  [string]$local:script = loadScript -scriptName 'xpathOfElement.js'
  $local:rawjson = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($local:script,$local:element,'')).ToString()
  write-debug ('Javascript-generated XPath = "{0}"' -f $local:rawjson)

  return $local:rawjson
}


<#
.SYNOPSIS
  Returns the CSS path to the provided Selenium page element
.DESCRIPTION
  Runs the javascript code through Selenium and returns the CSS path to the provided Selenium page element

.EXAMPLE
  $javascript_generated_css_selector_of_element = cssSelectorOfElement -element_ref ([ref] $element)

.LINK
  # http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed	

.NOTES
  TODO: http://joseoncode.com/2011/11/24/sharing-powershell-modules-easily/	
  VERSION HISTORY
  2015/06/07 Initial Version
#>

function cssSelectorOfElement {

  param(
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref)
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:rawjson = $null
  [string]$local:script = loadScript -scriptName 'cssSelectorOfElement.js'
  $local:rawjson = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($local:script,$local:element,'')).ToString()
  write-debug ('Javascript-generated CSS selector: "{0}"' -f $local:rawjson)
  return $local:rawjson
}


<#
.SYNOPSIS
  Returns the PSCustomObject of attributes of the provided Selenium page element
.DESCRIPTION
  Runs the javascript code through Selenium and returns the PSCustomObject of attributes of the provided Selenium page element

.EXAMPLE
  format-list -inputObject (getAttributes ([ref] $element))
  type      : checkbox
  value     : None
  id        : 7a18efeb-427c-4eec-880d-13cbec2bec17
  name      : check

.NOTES
  VERSION HISTORY
  2019/05/15 Initial Version
#>

function getAttributes {
  param(
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref)
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:rawjson = $null

  [string]$local:script = loadScript -scriptName 'getAttributes.js'

  # TODO: optionally drop JSON.stringify
  # System.Collections.Generic.Dictionary`2[System.String,System.Object]
  # $local:result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($local:script,$local:element,$true)).ToString()
  # write-debug 'Javascript-generated Attributes'
  # if ($DebugPreference -eq 'Continue') {
  #  write-output $local:result | format-table
  # }
  $local:rawjson = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($local:script,$local:element,$true)).ToString()
  write-debug ('Javascript-generated Attribute json = "{0}"' -f $local:rawjson)
  $local:result = ConvertFrom-Json -InputObject $local:rawjson
  return $local:result
}



<#
.SYNOPSIS
    Extracts match
.DESCRIPTION
  Extracts match from a text, e.g. from some $element.Text or $element.GetAttribute('innerHTML')

.EXAMPLE
  $firstitem = $null
  $capturing_match_expression = '(?<firstitem>\d+)$'
  extract_match -Source $text -capturing_match_expression $capturing_match_expression -label 'firstitem' -result_ref ([ref]$firstitem)

.LINK

.NOTES
  VERSION HISTORY
  2015/06/07 Initial Version
#>

function extract_match {
  param(
    [string]$source,
    [string]$capturing_match_expression,
    [string]$label,
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)
  )
  write-debug ('Extracting from {0}' -f $source)
  write-debug ('Extracting expression {0}' -f $capturing_match_expression)
  write-debug ('Extracting tag {0}' -f $label)
  $local:rawjsons = {}
  $local:rawjsons = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  if  ( $local:rawjsons -ne $null ) {
    write-debug 'extract_match:'
    write-debug $local:rawjsons
  }
  $result_ref.Value = $local:rawjsons.Media
}


<#
.SYNOPSIS
  Highlights page element
.DESCRIPTION
  Highlights page element by executing Javascript through Selenium

.EXAMPLE
        highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$element) [ -delay 1500 ] [-color 'red']
.LINK

.NOTES
  VERSION HISTORY
  2015/06/07 Initial Version
#>

function highlight {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [String]$color = 'yellow',
    [int]$delay = 300
  )
  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,"color: ${color}; border: 4px solid ${color};")
  start-sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'')
}


<#
.SYNOPSIS
  Highlights page element
.DESCRIPTION
  Highlights page element by executing Javascript through Selenium

.EXAMPLE
      highlightElement ([ref]$selenium) ([ref]$element) -delay 1500 -color 'green'
.LINK

.NOTES
  VERSION HISTORY
  2019/05/16 Initial Version
#>

function highlightElement {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [String]$color = 'yellow', # unused
    [int]$delay = 300
  )


  [string]$local:script = loadScript -scriptName 'highlightElement.js'

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

  # [org.openqa.selenium.Rectangle]$elementRect = $element_ref.Value.getRect()
  # Method invocation failed because [OpenQA.Selenium.Remote.RemoteWebElement] does not contain a method named 'getRect'.

  [System.Drawing.Point]$elementLocation = $element_ref.Value.Location
  [System.Drawing.Size]$elementSize = $element_ref.Value.Size
  # alternative is .Coordinates property + .LocationInViewport property
  # [OpenQA.Selenium.Interactions.Internal.ICoordinates]$elementCoordinates = $element_ref.Value.Coordinates
  # [System.Drawing.Point]$elementLocation = $elementCoordinates.LocationInViewport

  # TODO: try...catch

  write-debug ("{0}`nhighlight_create(arguments[0],arguments[1],arguments[2],arguments[3]);" -f $local:script)
  write-debug ('y = {0}' -f $elementLocation.y)
  write-debug ('x = {0}' -f $elementLocation.x)
  write-debug ('width = {0}' -f $elementSize.width)
  write-debug ('height = {0}' -f $elementSize.height)

  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript(("{0}`nhighlight_create(arguments[0],arguments[1],arguments[2],arguments[3]);" -f $local:script), $elementLocation.y, $elementLocation.x, $elementSize.width, $elementSize.height)
  start-sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript(("{0}`nhighlight_remove();" -f $local:script))
}

<#
.SYNOPSIS
  Highlights page element
.DESCRIPTION
  Highlights page element by executing Javascript through Selenium

.EXAMPLE
      highlight_new -element ([ref]$element)  -selenium_ref ([ref]$selenium)  -delay 1500 -color 'green'
.LINK

.NOTES
  VERSION HISTORY
  2015/06/07 Initial Version
#>

function highlight_new {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [OpenQA.Selenium.IWebElement]$element,
    [string]$color = 'yellow',
    [int]$delay = 300
  )

  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  if ($selenium_ref.Value -eq $null) {
     throw 'Selenium object must be defined to highight page element'
  }
  [string]$local:script =  ('color: {0}; border: 4px solid {0};' -f $color )
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,$local:script)
  start-sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')
}

<#
.SYNOPSIS
  Flashes page element
.DESCRIPTION
  Flashes page element by executing Javascript through Selenium

.EXAMPLE
  flash -element ([ref]$element) -selenium_ref ([ref]$selenium)
.LINK

.NOTES
  VERSION HISTORY
  2018/07/04 Initial Version
#>

function flash {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [OpenQA.Selenium.IWebElement]$element,
    [string]$color = 'rgb(0,200,0)' # TODO: map the color
  )

  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  if ($selenium_ref.Value -eq $null) {
    throw 'Selenium object must be defined to highight page element'
  }

  [string]$bgcolor = $element.getCssValue('background-color')
  # write-debug ('Original color: {0}' -f $bgcolor )

  for ($i = 0; $i -lt 3; $i++) {
    changeColor -color $color -element $element -selenium_ref $selenium_ref
    changeColor -color $bgcolor -element $element -selenium_ref $selenium_ref
  }
}

function changeColor {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [OpenQA.Selenium.IWebElement]$element,
    [string]$color = 'rgb(0,200,0)'
  )

  # write-debug ('Changing color to {0}' -f $color )
  if ($selenium_ref.Value -eq $null) {
     throw 'Selenium object must be defined to highight page element'
  }
  [string]$local:script = ("arguments[0].style.backgroundColor = '{0}'" -f $color )
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript($local:script,$element)
}

<#
.SYNOPSIS
  Finds page element
.DESCRIPTION
  Finds page element by executing appropriate FindElement, By, Wait through Selenium

.EXAMPLE
  $link_alt_text = 'Shore Excursions'
  $element = $null
  $xpath = ('img[@alt="{0}"]' -f $link_alt_text)
  find_page_element_by_xpath ([ref]$selenium) ([ref]$element) $xpath

.LINK

.NOTES
  VERSION HISTORY
  2015/06/21 Initial Version
#>

function find_page_element_by_xpath {
  param(
    [System.Management.Automation.PSReference]$selenium_driver_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [string]$xpath,
    [int]$wait_seconds = 10
  )
  if ($xpath -eq '' -or $xpath -eq $null) {
    return
  }
  $local:element = $null
  [OpenQA.Selenium.Remote.RemoteWebDriver]$local:selenum_driver = $selenium_driver_ref.Value
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($local:selenum_driver,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
  } catch [exception]{
    write-debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
  }

  $local:element = $local:selenum_driver.FindElement([OpenQA.Selenium.By]::XPath($xpath))
  $element_ref.Value = $local:element
}

<#
TODO: implement the helper methfs for the rest of By's
e.g.


<input id="searchInput" name="search" type="search" size="20" autofocus="autofocus" accesskey="F" dir="auto" results="10" autocomplete="off" list="suggestions">

https://www.wikipedia.org/
#>

<#
.SYNOPSIS
  Finds page element
.DESCRIPTION
  Finds page element by executing appropriate FindElement, By, Wait through Selenium

.EXAMPLE
  $link_alt_text = 'Shore Excursions'
  $element = $null
  $css_selector = ('img[alt="{0}"]' -f $link_alt_text)
  find_page_element_by_css_selector ([ref]$selenium) ([ref]$element) $css_selector

.LINK

.NOTES
  VERSION HISTORY
  2015/06/21 Initial Version
#>

function find_page_element_by_css_selector {
  param(
    [System.Management.Automation.PSReference]$selenium_driver_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [string]$css_selector,
    [int]$wait_seconds = 10
  )
  if ($css_selector -eq '' -or $css_selector -eq $null) {
    return
  }
  $local:status = $false
  $local:element = $null
  [OpenQA.Selenium.Remote.RemoteWebDriver]$local:selenum_driver = $selenium_driver_ref.Value
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($local:selenum_driver,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
    $local:status = $true
  } catch [exception]{
    write-debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
  }
  if ($local:status) {
    $local:element = $local:selenum_driver.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
    $element_ref.Value = $local:element
  }
}


<#

# http://www.phpied.com/sleep-in-javascript/

function sleep(milliseconds) {
  var start = new Date().getTime();
  for (var i = 0; i < 1e7; i++) {
    if ((new Date().getTime() - start) > milliseconds){
      break;
    }
  }
}

#>


<#
.SYNOPSIS
  Finds element using specific method of finding : xpath, classname, css_selector etc.
.DESCRIPTION
  Receives either of the core Selenium locator strategies as named argument

.EXAMPLE
  $element = find_element2 -selector 'classname' -value $classname
  $element = find_element2 -selector 'xpath' -value $xpath
  $element = find_element2 -selector 'css_selector' -value $css_selector
  $element = find_element2 -selector 'id' -value $id
  $element = find_element2 -selector 'tagname' -value $tagsname
  $element = find_element2 -selector 'link_text' -value $link_text
  $element = find_element2 -selector 'partial_link_text' -value $partial_link_text

.LINK

.NOTES
  VERSION HISTORY
  2019/10/19 Initial Version

  See also:
  https://github.com/grock90/PSSelenium
#>

# Powershell version
function find_element2{
    param(
      [Parameter(Mandatory=$true,
                  ValueFromPipelineByPropertyName=$true)]
      [Validateset('classname', 'xpath', 'css_selector', 'id', 'tagname', 'link_text', 'partial_link_text')]
      $selector,
      [ValidateNotNull()]
      $value
    )

  $element = $null
  $wait_seconds = 5
  $wait_polling_interval = 50

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = new-object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = $wait_polling_interval

  switch ($selector)
    {
      'xpath'{
        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($value)))
        } catch [exception]{
          write-debug ("Exception : {0} ...`nxpath='{1}'" -f (($_.Exception.Message) -split "`n")[0],$value)
        }
        $element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($value))
      }
      'css_selector'{
        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($value)))
        } catch [exception]{
          write-debug ("Exception : {0} ...`ncss_selector='{1}'" -f (($_.Exception.Message) -split "`n")[0],$value)
        }
        $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($value))
      }

      'link_text'{
        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::LinkText($value)))
        } catch [exception]{
          write-debug ("Exception : {0} ...`nlink_te='{1}'" -f (($_.Exception.Message) -split "`n")[0],$value)
        }
        $element = $selenium.FindElement([OpenQA.Selenium.By]::LinkText($value))
      }
      'id'{
        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id($value)))
        } catch [exception]{
          write-debug ("Exception : {0} ...`nid='{1}'" -f (($_.Exception.Message) -split "`n")[0], $value)
        }
        $element = $selenium.FindElement([OpenQA.Selenium.By]::Id($value))
      }

      'tag_name'{
        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::TagName($value)))
        } catch [exception]{
          write-debug ("Exception : {0} ...`ntag_name='{1}'" -f (($_.Exception.Message) -split "`n")[0],$value)
        }
        $element = $selenium.FindElement([OpenQA.Selenium.By]::TagName($value))
      }
      'classname'{
        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName($value)))

        } catch [exception]{
          write-debug ("Exception : {0} ...`nclassname='{1}'" -f (($_.Exception.Message) -split "`n")[0], $value)
        }
        $element = $selenium.FindElement([OpenQA.Selenium.By]::ClassName($value))
      }
      'partial_link_text'{
        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::PartialLinkText($value)))
        } catch [exception]{
          write-debug ("Exception : {0} ...`npartial_link_text='{1}'" -f (($_.Exception.Message) -split "`n")[0],$value)
        }
        $element = $selenium.FindElement([OpenQA.Selenium.By]::PartialLinkText($value))
      }
    }

  return $element
}
<#
.SYNOPSIS
  Finds element using specific method of finding : xpath, classname, css_selector etc.
.DESCRIPTION
  Receives aither of the core Selenium locator strategies as named argument

.EXAMPLE
  $element = find_element -xpath $xpath
  $element = find_element -classname $classname
  $element = find_element -css_selector $css_selector
  $element = find_element -id $id
  $element = find_element -tagname $tagsname
  $element = find_element -link_text $link_text
  $element = find_element -partial_link_text $partial_link_text

.LINK
  # https://chromium.googlesource.com/chromium/blink/+/master/Source/devtools/front_end/components/DOMPresentationUtils.js
        # http://stackoverflow.com/questions/1767219/mutually-exclusive-powershell-parameters
        # https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/By.html

.NOTES
  VERSION HISTORY
  2015/07/03 Initial Version
  2015/09/20 Removed old versions
  2018/07/22 Upated documentation
#>

function find_element {
  param(
    [Parameter(ParameterSetName = 'set_xpath')] $xpath,
    [Parameter(ParameterSetName = 'set_css_selector')] $css_selector,
    [Parameter(ParameterSetName = 'set_id')] $id,
    [Parameter(ParameterSetName = 'set_linktext')] $link_text,
    [Parameter(ParameterSetName = 'set_partial_link_text')] $partial_link_text,
    [Parameter(ParameterSetName = 'set_tagname')] $tag_name,
    [Parameter(ParameterSetName = 'set_classname')] $classname
  )


  # guard
  $implemented_options = @{
    'xpath' = $true;
    'css_selector' = $true;
    'id' = $true;
    'link_text' = $true;
    'partial_link_text' = $true;
    'tag_name' = $true;
    'classname' = $true;
  }

  $implemented.Keys | ForEach-Object { $option = $_
    if ($psBoundParameters.ContainsKey($option)) {
      if (-not $implemented_options[$option]) {
        Write-Output ('Option {0} i not implemented' -f $option)
      } else {
        # will find
      }
    }
  }
  if ($false) {
    write-output @psBoundParameters | Format-Table -AutoSize
  }
  $element = $null
  $wait_seconds = 5
  $wait_polling_interval = 50

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = $wait_polling_interval

  if ($css_selector -ne $null) {

    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
    } catch [exception]{
      write-debug ("Exception : {0} ...`ncss_selector='{1}'" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
    }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  }


  if ($xpath -ne $null) {
    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
    } catch [exception]{
      write-debug ("Exception : {0} ...`nxpath='{1}'" -f (($_.Exception.Message) -split "`n")[0],$xpath)
    }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
  }

  if ($link_text -ne $null) {
    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::LinkText($link_text)))

    } catch [exception]{
      write-debug ("Exception : {0} ...`nlink_te='{1}'" -f (($_.Exception.Message) -split "`n")[0],$link_text)
    }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::LinkText($link_text))
  }

  if ($tag_name -ne $null) {
    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::TagName($tag_name)))
    } catch [exception]{
      write-debug ("Exception : {0} ...`ntag_name='{1}'" -f (($_.Exception.Message) -split "`n")[0],$tag_name)
    }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::TagName($tag_name))
  }

  if ($partial_link_text -ne $null) {
    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::PartialLinkText($partial_link_text)))
    } catch [exception]{
      write-debug ("Exception : {0} ...`npartial_link_text='{1}'" -f (($_.Exception.Message) -split "`n")[0],$partial_link_text)
    }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::PartialLinkText($partial_link_text))
  }

  if ($classname -ne $null) {

    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName($classname)))

    } catch [exception]{
      write-debug ("Exception : {0} ...`nclassname='{1}'" -f (($_.Exception.Message) -split "`n")[0],$classname)
    }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::ClassName($classname))
  }

  if ($id -ne $null) {

    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id($id)))

    } catch [exception]{
      write-debug ("Exception : {0} ...`nid='{1}'" -f (($_.Exception.Message) -split "`n")[0],$id)
    }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::Id($id))
  }

  return $element
}


<#
.SYNOPSIS
  Finds a collection of elements using specific method of finding : xpath or css_selector
.DESCRIPTION
        Receives the
.EXAMPLE
  $elements = find_elements -css_selector $css_selector -parent $parent_element

.LINK

.NOTES
  VERSION HISTORY
  2015/10/03 Initial Version

#>

function find_elements {
  param(
    [Parameter(ParameterSetName = 'set_xpath')] $xpath,
    [Parameter(ParameterSetName = 'set_css_selector')] $css_selector,
    [OpenQA.Selenium.ISearchContext]$parent
  )


  # guard
  $implemented_options = @{
    'xpath' = $true;
    'css_selector' = $true;
  }

  $implemented.Keys | ForEach-Object { $option = $_
    if ($psBoundParameters.ContainsKey($option)) {

      if (-not $implemented_options[$option]) {

        Write-Output ('Option {0} i not implemented' -f $option)

      } else {
        # will find

      }
    }
  }
  if ($false) {
    Write-Output @psBoundParameters | Format-Table -AutoSize
  }
  $elements = $null
  $wait_seconds = 5
  $wait_polling_interval = 50

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = $wait_polling_interval
  if ($parent) {
     $parent_css_selector = cssSelectorOfElement ([ref] $parent )
     $parent_xpath = xpathOfElement([ref] $parent )

  } else {
     $parent= $selenium
     $parent_css_selector = ''
     $parent_xpath_selector = ''
  }

  if ($css_selector -ne $null) {
    $extended_css_selector = ('{0} {1}' -f $parent_css_selector, $css_selector)
    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($extended_css_selector)))
    } catch [exception]{
      write-debug ("Exception : {0} ...`ncss_selector='{1}'" -f (($_.Exception.Message) -split "`n")[0],$extended_css_selector )
    }
    $elements = $parent.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector))
  }


  if ($xpath -ne $null) {
    if ($parent_xpath -ne '') {
      $extended_xpath = $xpath
    } else {
      $extended_xpath = ('{0}/{1}' -f $parent_xpath, $xpath)
    }
    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($extended_xpath)))
    } catch [exception]{
      write-debug ("Exception : {0} ...`nxpath='{1}'" -f (($_.Exception.Message) -split "`n")[0],$extended_xpath)
    }

    $elements = $parent.FindElements([OpenQA.Selenium.By]::XPath($xpath))


  }

  return $elements
}


<#
.SYNOPSIS
  Finds a value or text of element using another element as a reference, and the selector of closest embedding element and the selector of the target element
.DESCRIPTION
  Finds a value or text of element using another element as a reference, and the selector of closest embedding element and the selector of the target element.
  Uses DOM `closest` method https://developer.mozilla.org/en-US/docs/Web/API/Element/closest that is similar to ancestor xpath
.EXAMPLE
  Find the 'add to card' button on http://store.demoqa.com/products-page/ starting from the price element
    $element = find_page_element_by_xpath -selenium_ref ([ref]$selenium) -xpath 'span[@class="currentprice"]'
    $result = find_via_closest -ancestor_locator 'form' -target_element_locator 'input[type="submit"]' -element_ref ([ref]$element)
  The result is equal to 'Add to Card'
.LINK	
  https://habr.com/company/ruvds/blog/416539/ (Russian)
  https://developer.mozilla.org/en-US/docs/Web/API/Element/closest
.NOTES
  VERSION HISTORY
  2018/07/23 Initial Version
#>

function find_via_closest {
  param(
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref),
    [String] $ancestor_locator,
    [String] $target_element_locator
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:rawjson = $null
  <#
  # variable-interpolated no-extra-argument version of the script
  # is possible but is discoraged
  [string] $script = @"
  var element = arguments[0];
  var ancestorLocator = arguments[1];
  var targetElementLocator = arguments[2];
  /* alert('ancestorLocator = ' + ancestorLocator); */
  var targetElement = element.closest(ancestorLocator).querySelector(targetElementLocator);
  targetElement.scrollIntoView({ behavior: 'smooth' });
  return targetElement.text || targetElement.getAttribute('value');
"@
  $local:rawjson = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript( $local:script, $local:element, $ancestor_locator, $target_element_locator )).ToString()
  write-debug ('Result = "{0}"' -f $local:rawjson)
#>
$script = @"
  var element = arguments[0];
  var ancestorLocator = '${ancestor_locator}';
  var targetElementLocator = '${target_element_locator}';
  /* alert('ancestorLocator = ' + ancestorLocator); */
  var targetElement = element.closest(ancestorLocator).querySelector(targetElementLocator);
  targetElement.scrollIntoView({ behavior: 'smooth' });
  return targetElement.text || targetElement.getAttribute('value');
"@
  <#
  # WIP: refactoring
[string] $script = @"
  findViaClosest = function (element, ancestorLocator, targetElementLocator) {
    /* alert('ancestorLocator = ' + ancestorLocator); */
    var targetElement = element.closest(ancestorLocator).querySelector(targetElementLocator);
    targetElement.scrollIntoView({ behavior: 'smooth' });
    return targetElement.text || targetElement.getAttribute('value');
  }
  var element = arguments[0];
  var ancestorLocator = arguments[1];
  var targetElementLocator = arguments[2];
  return findViaClosest (element, ancestorLocator, targetElementLocator);
"@
  #>
  $local:rawjson = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript( $local:script, $local:element,'')).ToString()
  write-debug ('Result = "{0}"' -f $local:rawjson)

  return $local:rawjson

}


<#
.SYNOPSIS
  Utility to return the computed size of the image https://stackoverflow.com/questions/10076031/naturalheight-and-naturalwidth-property-new-or-deprecated
.DESCRIPTION
  Runs Javascript on the page to return the image naturalWidth property.
.EXAMPLE

   $image_locator = '#hs_cos_wrapper_post_body > a:nth-child(3) > img'
   $result = check_image_ready -selenium_ref ([ref]$selenium) -element_locator $image_locator #  -debug

.LINK
  See also https://www.w3.org/TR/html5/embedded-content-0.html#the-img-element, https://stackoverflow.com/questions/29999515/get-final-size-of-background-image

.NOTES
  Based on: https://automated-testing.info/t/proverit-chto-background-image-zagruzilsya-na-stranicze/21424
  NOTE: One can use this function to compute the naturalWidth property of the regular image but the page background
  image https://www.w3schools.com/cssref/pr_background-image.asp does not have a dedicated tag and will fail to get naturalWidth.
  Therefore this method will noe suit and detect when the background image is finished loading.
  VERSION HISTORY
  2018/08/27 Initial Version
#>

function check_image_ready {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [switch]$debug,
    [String]$element_locator = 'body'
  )
  if ($selenium_ref.Value -eq $null) {
    throw 'Selenium object must be defined to check_image_ready'
  }
  $run_debug = [bool]$PSBoundParameters['debug'].IsPresent
  if ($run_debug) {
    write-debug 'in check_image_ready'
  }

[String]$local:script =
@"
check_image_ready = function(selector, debug) {
  var nodes = document.querySelectorAll(selector);
  var element = nodes[0];
  if (debug) {
    try {

      // alert('typeof element.complete: ' + typeof(element.complete)) ;
      var element_complete = 'undef';
      if (typeof(element.complete) != 'undefined') {
        element_complete = element.complete.toString();
      }
      alert('element.complete = ' + element_complete);
    } catch (error) {
      // TypeError: Cannot read property 'toString' of undefined
      alert(error.toString());
    }
    try {
      // does not work inline:
      //  alert('element.naturalWidth = ' + (typeof(element.naturalWidth) != 'undefined') ?  element.naturalWidth.toString() : '-1');
      var element_naturalWidth = '-1';
      if (typeof(element.naturalWidth) != 'undefined') {
        element_naturalWidth = element.naturalWidth.toString();
      }
      alert('element.naturalWidth = ' + element_naturalWidth);
    } catch (error) {
      alert(error.toString());
    }
  }
  return (element.complete && typeof element.naturalWidth != "undefined" && element.naturalWidth > 0) ? element.naturalWidth : -1
}

var selector = arguments[0];
var debug = arguments[1];
return check_image_ready(selector, debug);
"@

  write-debug ('Running the script : {0}' -f $local:script )
  # NOTE: with 'Microsoft.PowerShell.Commands.WriteErrorException,check_image_ready' will be thrown if write-error is used here instead of write-debug

  $local:rawjson = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value).ExecuteScript($local:script, $element_locator, $run_debug  )
  write-debug ('Result = {0}' -f $local:rawjson)

  return $local:rawjson
}

<#
.SYNOPSIS
  Utility to enter text intothe element
.DESCRIPTION
  Runs Javascript on the page to enter text intothe element
.EXAMPLE
.LINK
.NOTES
  VERSION HISTORY
  2020/06/18 Initial Version
#>
# fastSetText
function setValue {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [Parameter(ParameterSetName = 'set_element')] [System.Management.Automation.PSReference]$element_ref = $null,
    [Parameter(ParameterSetName = 'set_locator')] [String]$element_locator = $null,
    [String]$text = '',
    [bool]$run_debug
    # [switch]$debug
    # ParameterNameAlreadyExistsForCommand
    # setValue : A parameter with the name 'Debug' was defined multiple times for the command
  )
  # $run_debug = [bool]$PSBoundParameters['debug'].IsPresent
  [OpenQA.Selenium.IJavaScriptExecutor]$local:js = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value)
  [String]$local:functionScript =  @'
  // based on: https://github.com/selenide/selenide/blob/master/src/main/java/com/codeborne/selenide/commands/SetValue.java
    var setValue = function(element, text) {
    if (element.getAttribute('readonly') != undefined) return 'Cannot change value of readonly element';
    if (element.getAttribute('disabled') != undefined) return 'Cannot change value of disabled element';
    element.focus();
    var maxlength = element.getAttribute('maxlength') == null ? -1 : parseInt(element.getAttribute('maxlength'));
    element.value = maxlength == -1 ? text : text.length <= maxlength ? text : text.substring(0, maxlength);
    return null;
  };
'@
  if ($element_ref -ne $null) {
    [string]$local:script = ( $local:functionScript + @'
      var element = arguments[0];
      var text = arguments[1];
      var debug = arguments[2];

      setValue(element, text);
      return;
'@ )
    # NOTE: with 'Microsoft.PowerShell.Commands.WriteErrorException,check_image_ready' will be thrown if write-error is used here instead of write-debug
    # TODO : support $element_locator
    <#
     Exception calling "ExecuteScript" with "4" argument(s): "Argument is of anillegal typeFalse
    #>
    [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
    $local:element_argument = $local:element
  }
  if ($element_locator -ne $null -and $element_ref -eq $null) {
    $local:element_argument = $element_locator
    [string]$local:script =  (  $local:functionScript + @'
      var selector = arguments[0];
      var text = arguments[1];
      var debug = arguments[2];
      var nodes = window.document.querySelectorAll(selector);
      if (nodes) {
        setValue(nodes[0], text);
      }
      return;
'@ )
  }
  if ($run_debug) {
    write-debug ('Running the script: {0}' -f $local:script )
    write-debug ('Entering text: {0}' -f $text )
  }
  $local:js.ExecuteScript($local:script, $local:element_argument, $text, $run_debug )
}
