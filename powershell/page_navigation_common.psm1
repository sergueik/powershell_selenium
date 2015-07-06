<#
.SYNOPSIS
	Returns the Xpath to the provided Selenium page element
.DESCRIPTION
	Runs the javascript code through Selenium and returns the Xpath path to the provided Selenium page element
	
.EXAMPLE
	$javascript_generated_xpath_to_element = get_xpath_of ([ref] $element)

.LINK
	# https://chromium.googlesource.com/chromium/blink/+/master/Source/devtools/front_end/components/DOMPresentationUtils.js
	
.NOTES
	VERSION HISTORY
	2015/07/03 Initial Version
#>


function get_xpath_of {
  param(
    <# there is no need to explicitly pass the reference to selenium 
    [System.Management.Automation.PSReference]$selenium_ref,
    #>
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref)
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:result = $null

  [string]$local:script = @"
 function get_xpath_of(element) {
     var elementTagName = element.tagName.toLowerCase();
     if (element.id != '') {
         return 'id("' + element.id + '")';
         // alternative : 
         // return '*[@id="' + element.id + '"]';
     } else if (element.name && document.getElementsByName(element.name).length === 1) {
         return '//' + elementTagName + '[@name="' + element.name + '"]';
     }
     if (element === document.body) {
         return '/html/' + elementTagName;
     }
     var sibling_count = 0;
     var siblings = element.parentNode.childNodes;
     siblings_length = siblings.length;
     for (cnt = 0; cnt < siblings_length; cnt++) {
         var sibling_element = siblings[cnt];
         if (sibling_element.nodeType !== 1) { // not ELEMENT_NODE
             continue;
         }
         if (sibling_element === element) {
             return get_xpath_of(element.parentNode) + '/' + elementTagName + '[' + (sibling_count + 1) + ']';
         }
         if (sibling_element.nodeType === 1 && sibling_element.tagName === elementTagName) {
             sibling_count++;
         }
     }
     return;
 };
 return get_xpath_of(arguments[0]);
"@

  $local:result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($local:script,$local:element,'')).ToString()
  Write-Debug ('Javascript-generated XPath = "{0}"' -f $local:result)

  return $local:result
}


<#
.SYNOPSIS
	Returns the CSS path to the provided Selenium page element
.DESCRIPTION
	Runs the javascript code through Selenium and returns the CSS path to the provided Selenium page element
		
.EXAMPLE
	$javascript_generated_css_selector_of_element = get_css_selector_of ([ref] $element)

.LINK
	# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed	
	
.NOTES
	TODO: http://joseoncode.com/2011/11/24/sharing-powershell-modules-easily/	
	VERSION HISTORY
	2015/06/07 Initial Version
#>

function get_css_selector_of {

  param(
    <# there is no need to explicitly pass the reference to selenium 
    [System.Management.Automation.PSReference]$selenium_ref,
    #>
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref)
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:result = $null

  [string]$local:script = @"
function get_css_selector_of(element) {

    if (!(element instanceof Element))
        return;
    var path = [];
    while (element.nodeType === Node.ELEMENT_NODE) {
        var selector = element.nodeName.toLowerCase();
        if (element.id) {
            if (element.id.indexOf('-') > -1) {
                selector += '[id = "' + element.id + '"]';
            } else {
                selector += '#' + element.id;
            }
            path.unshift(selector);
            break;
        } else {
            var element_sibling = element;
            var sibling_cnt = 1;
            while (element_sibling = element_sibling.previousElementSibling) {
                if (element_sibling.nodeName.toLowerCase() == selector)
                    sibling_cnt++;
            }
            if (sibling_cnt != 1)
                selector += ':nth-of-type(' + sibling_cnt + ')';
        }
        path.unshift(selector);
        element = element.parentNode;
    }
    return path.join(' > ');
} // invoke
return get_css_selector_of(arguments[0]);
"@

  $local:result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($local:script,$local:element,'')).ToString()


  Write-Debug ('Javascript-generated CSS selector = "{0}"' -f $local:result)
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
  Write-Debug ('Extracting from {0}' -f $source)
  $local:results = {}
  $local:results = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  Write-Debug 'extract_match:'
  Write-Debug $local:results
  $result_ref.Value = $local:results.Media
}

<#
.SYNOPSIS
	Highlights page element
.DESCRIPTION
	Highlights page element by executing Javascript through Selenium
	
.EXAMPLE
        highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$element) -delay 1500
.LINK
	
.NOTES
	VERSION HISTORY
	2015/06/07 Initial Version
#>

function highlight {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [int]$delay = 300
  )
  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'color: yellow; border: 4px solid yellow;')
  Start-Sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'')
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
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
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
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
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



# http://stackoverflow.com/questions/1767219/mutually-exclusive-powershell-parameters
# https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/By.html

function find_element {
  param(
    [Parameter(ParameterSetName = 'set_xpath')] $xpath,
    [Parameter(ParameterSetName = 'set_css_locator')] $css,
    [Parameter(ParameterSetName = 'set_id')] $id,
    [Parameter(ParameterSetName = 'set_linktext')] $linktext,
    [Parameter(ParameterSetName = 'set_partial_link_text')] $partial_link_text,
    [Parameter(ParameterSetName = 'set_css_tagname')] $tagname,
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref)
  )


  # guard
  $implemented_options = @{
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
    Write-Output @psBoundParameters | Format-Table -AutoSize
  }

  # fall back to calling legacy implementation

  if ($css -ne $null) {
    $local:element = $null

    find_page_element_by_css_selector ([ref]$selenium) ([ref]($local:element)) -css_selector $css
    return local:element

  }


  if ($xpath -ne $null) {

    $local:element = $null
    $xpath = ('img[@alt="{0}"]' -f $link_alt_text)
    find_page_element_by_xpath ([ref]$selenium) ([ref]($local:element)) $xpath

    return local:element

  }

}




