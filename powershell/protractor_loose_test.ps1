#Copyright (c) 2021 Serguei Kouzmine
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

# see also
#
# in https://github.com/sergueik/jProtractor

param(
  [string]$browser = 'chrome',
  [switch]$grid,
  [switch]$pause
)

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)
# for intro to Angular directives see https://www.w3schools.com/angular/angular_directives.asp
[string]$model_locator_script = @'
var findByModel = function(model, using, rootSelector) {
    var root = document.querySelector(rootSelector || 'body');
    using = using || '[ng-app]';
    if (angular.getTestability) {
        return angular.getTestability(root).
        findModels(using, model, true);
    }
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var selector = '[' + prefixes[p] + 'model="' + model + '"]';
        var elements = using.querySelectorAll(selector);
        if (elements.length) {
            return elements;
        }
    }
};
var using = arguments[0] || document;
var model = arguments[1];
var rootSelector = arguments[2];
return findByModel(model, using, rootSelector);
'@
[string]$binding_locator_script = @'
var findBindings = function(binding, exactMatch, using, rootSelector) {
    var root = document.querySelector(rootSelector || 'body');
    using = using || document;
    if (angular.getTestability) {
        return angular.getTestability(root).
        findBindings(using, binding, exactMatch);
    }
    var bindings = using.getElementsByClassName('ng-binding');
    var matches = [];
    for (var i = 0; i < bindings.length; ++i) {
        var dataBinding = angular.element(bindings[i]).data('$binding');
        if (dataBinding) {
            var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
            if (exactMatch) {
                var matcher = new RegExp('({|\\s|^|\\|)' +
                    /* See http://stackoverflow.com/q/3561711 */
                    binding.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&') +
                    '(}|\\s|$|\\|)');
                if (matcher.test(bindingName)) {
                    matches.push(bindings[i]);
                }
            } else {
                if (bindingName.indexOf(binding) != -1) {
                    matches.push(bindings[i]);
                }
            }
        }
    }
    return matches; /* Return the whole array for webdriver.findElements. */
};

var using = arguments[0] || document;
var binding = arguments[1];
var rootSelector = arguments[2];

var exactMatch = arguments[3];
if (typeof exactMatch === 'undefined') {
    exactMatch = true;
}

return findBindings(binding, exactMatch, using, rootSelector);
'@
[string]$repeater_locator_script = @'
var repeaterMatch = function(ngRepeat, repeater, exact) {
  if (exact) {
    return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
    split('=')[0].trim() == repeater;
  } else {
    return ngRepeat.indexOf(repeater) != -1;
  }
}

var findAllRepeaterRows = function(using, repeater) {

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        rows.push(repeatElems[i]);
      }
    }
  }
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        var elem = repeatElems[i];
        while (elem.nodeType != 8 ||
          !(elem.nodeValue.indexOf(repeater) != -1)) {
          if (elem.nodeType == 1) {
            rows.push(elem);
          }
          elem = elem.nextSibling;
        }
      }
    }
  }
  return rows;
};
var using = arguments[0] || document;
var repeater = arguments[1];
return findAllRepeaterRows(using, repeater);
'@
[string]$options_locator_script = @'
var findByOptions = function(options, using) {
    using = using || document;
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var selector = '[' + prefixes[p] + 'options="' + options + '"] option';
        var elements = using.querySelectorAll(selector);
        if (elements.length) {
            return elements;
        }
    }
};

var using = arguments[0] || document;
var options = arguments[1];
return findByOptions(options, using);
'@
[string]$button_text_locator_script = @'
var findByButtonText = function(searchText, using) {
    using = using || document;
    var elements = using.querySelectorAll('button, input[type="button"], input[type="submit"]');
    var matches = [];
    for (var i = 0; i < elements.length; ++i) {
        var element = elements[i];
        var elementText;
        if (element.tagName.toLowerCase() == 'button') {
            elementText = element.textContent || element.innerText || '';
        } else {
            elementText = element.value;
        }
        if (elementText.trim() === searchText) {
            matches.push(element);
        }
    }
    return matches;
};
var using = arguments[0] || document;
var searchText = arguments[1];
return findByButtonText(searchText, using);
'@
$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid -shared_assemblies $shared_assemblies
} else {
  $selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies
}
$base_url = 'http://juliemr.github.io/protractor-demo/'

$selenium.Navigate().GoToUrl($base_url)

$title = $selenium.Title
sleep -millisecond 100
[NUnit.Framework.Assert]::AreEqual('Super Calculator', $title)

$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($model_locator_script,$null,'first',$null))
[NUnit.Framework.Assert]::IsTrue(($elements -ne $null))
$first = $elements[0]
$first.Clear()
$first.sendKeys('40')

$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($model_locator_script,$null,'second',$null))
[NUnit.Framework.Assert]::IsNotNull($elements)
$second = $elements[0]
$second.Clear()
$second.sendKeys('2')


$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($options_locator_script,$null,'value for (key, value) in operators',$null))
[NUnit.Framework.Assert]::IsNotNull($elements)
$operator = $elements[0]
$operator.Click()

$goButton = $selenium.FindElement([OpenQA.Selenium.By]::Id('gobutton'))
[NUnit.Framework.Assert]::AreEqual('Go!', $goButton.Text) # Contains
$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($button_text_locator_script,$null,'Go!',$null))
[NUnit.Framework.Assert]::IsNotNull($elements)
$goButton = $elements[0]
[NUnit.Framework.Assert]::That(($goButton.Text -match 'Go!')) # Contains
$goButton.Click()

$script_timeout = 120
# only available in latest versions of Selenium assembly
try {
  [void]($selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script_timeout)))
} catch [System.Management.Automation.RuntimeException] { # NOTE: fully specified class
  write-output ('Exception (ignored): {0}' -f $_.Exception.Message)
}

$wait_seconds = 10
$wait_polling_interval = 50

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
$wait.PollingInterval = $wait_polling_interval
$wait.IgnoreExceptionTypes([OpenQA.Selenium.WebDriverTimeoutException],[OpenQA.Selenium.WebDriverException])
# TODO: predicate
# see for Java
# https://www.techbeamers.com/webdriver-fluent-wait-command-examples/
# https://gist.github.com/djangofan/cd96628f9ae2b4927c4d
# https://www.codeproject.com/Articles/787565/Lightweight-Wait-Until-Mechanism

try {
  [void]$wait.Until([Func[[OpenQA.Selenium.IWebDriver],[Bool]]] {
    param(
      [OpenQA.Selenium.IWebDriver] $driver
    )
    # write-host 'Inside Wait'
    $elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($binding_locator_script,$null,'latest',$null))
    if (($elements -eq $null) -or ($elements.size -eq 0)) {
      return $false
    }
    $element = $elements[0]
    if ($element.Text -match '[0-9]+') {
      return $true
    } else {
      return $false
    }
  })

  $elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($binding_locator_script,$null,'latest',$null))
  [NUnit.Framework.Assert]::IsNotNull($elements)
  $latest = $elements[0]
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::TextToBePresentInElement($latest, '42'))
  highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$latest) -Delay 150
  [NUnit.Framework.Assert]::AreEqual('42', $latest.Text )

} catch [OpenQA.Selenium.WebDriverTimeoutException]{
  write-output ('Timeout Exception : {0}' -f (($_.Exception.Message) -split "`n")[0])
} catch [Exception]{
  write-output ("Exception : {0} ...`n{1}" -f (($_.Exception.Message) -split "`n")[0],$_.Exception.Type)
}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
