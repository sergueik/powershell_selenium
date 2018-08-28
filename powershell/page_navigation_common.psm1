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
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref)
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:result = $null

  [string]$local:script = @"
 function get_xpath_of(element) {
     var elementTagName = element.tagName.toLowerCase();
     if (element.id != '') {
         return '//' + elementTagName + '[@id="' + element.id + '"]';
         // alternative ?
         // return 'id("' + element.id + '")';
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
             return sibling_count > 0 ? get_xpath_of(element.parentNode) + '/' + elementTagName + '[' + (sibling_count + 1) + ']' : get_xpath_of(element.parentNode) + '/' + elementTagName;
         }
         if (sibling_element.nodeType === 1 && sibling_element.tagName.toLowerCase() === elementTagName) {
             sibling_count++;
         }
     }
     return;
 };
 return get_xpath_of(arguments[0]);
"@

  $local:result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($local:script,$local:element,'')).ToString()
  write-debug ('Javascript-generated XPath = "{0}"' -f $local:result)

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

  write-debug ('Javascript-generated CSS selector: "{0}"' -f $local:result)
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
  $local:results = {}
  $local:results = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  if  ( $local:results -ne $null ) {
    write-debug 'extract_match:'
    write-debug $local:results
  }
  $result_ref.Value = $local:results.Media
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
  Start-Sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'')
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
  Start-Sleep -Millisecond $delay
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
  Receives aither of the core Selenium locator strategies as named argument
.EXAMPLE
  $element = find_element -classname $classname
  $element = find_element -css_selector $css_selector
  $element = find_element -id $id
  $element = find_element -tagname $tagsname
  $element = find_element -link_text $link_text

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
    Write-Output @psBoundParameters | Format-Table -AutoSize
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
     $parent_css_selector = get_css_selector_of ([ref] $parent )
     $parent_xpath = get_xpath_of([ref] $parent )

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
  [string]$local:result = $null
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
  $local:result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript( $local:script, $local:element, $ancestor_locator, $target_element_locator )).ToString()
  write-debug ('Result = "{0}"' -f $local:result)
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
  $local:result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript( $local:script, $local:element,'')).ToString()
  write-debug ('Result = "{0}"' -f $local:result)

  return $local:result

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
  # NOTE: with 'Microsoft.PowerShell.Commands.WriteErrorException,check_image_ready' will be thrown if write-erroris used here instead of write-debug

  $local:result = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value).ExecuteScript($local:script, $element_locator, $run_debug  )
  write-debug ('Result = {0}' -f $local:result)

  return $local:result
}