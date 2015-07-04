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
	$javascript_generated_css_path_to_element = get_css_path_of ([ref] $element)

.LINK
	# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed	
	
.NOTES
	TODO: http://joseoncode.com/2011/11/24/sharing-powershell-modules-easily/	
	VERSION HISTORY
	2015/06/07 Initial Version
#>

function get_css_path_of {

  param(
   <# there is no need to explicitly pass the reference to selenium 
    [System.Management.Automation.PSReference]$selenium_ref,
    #>
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref)
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:result = $null

  [string]$local:script = @"
function get_css_selector_of(el) {
    if (!(el instanceof Element))
        return;
    var path = [];
    while (el.nodeType === Node.ELEMENT_NODE) {
        var selector = el.nodeName.toLowerCase();
        if (el.id) {
            if (el.id.indexOf('-') > -1) {
                selector += '[id = "' + el.id + '"]';
            } else {
                selector += '#' + el.id;
            }
            path.unshift(selector);
            break;
        } else {
            var el_sib = el,
                cnt = 1;
            while (el_sib = el_sib.previousElementSibling) {
                if (el_sib.nodeName.toLowerCase() == selector)
                    cnt++;
            }
            if (cnt != 1)
                selector += ':nth-of-type(' + cnt + ')';
        }
        path.unshift(selector);
        el = el.parentNode;
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
	$css_selector = ('img[alt="{0}"]' -f $link_alt_text)
	find_page_element_by_css_selector ([ref]$selenium) ([ref]$element) $css_selector

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
