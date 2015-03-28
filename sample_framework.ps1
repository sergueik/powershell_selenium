# http://www.ifunky.net/Blog/?tag=/Powershell
Add-Type @'
using System.Collections.Generic;

public class SmokeTestResults
{
 private IList<SmokeTestResult> smokeTestResults = new List<SmokeTestResult>();

 public IList<SmokeTestResult> Results { 
 get { return smokeTestResults; }
 } 

 public int Errors {get; set;} 
}

public class SmokeTestResult
{
 public string StoryTitle {get; set;} 
 public bool Passed {get; set;} 
 public string ErrorMessage {get; set;}
}
'@

$script:driver = $null
$script:baseUrl = $null
$script:buildNumber = $null
$script:smokeTestResults = $null
$script:testsAsWarnings = $true

function InitializeSmokeTests () {
  param(
    [ValidateNotNull()]
    $baseUrl,
    [ValidateNotNull()]
    $buildNumber,
    [ValidateNotNull()]
    $scriptBlockToExecute,
    [bool]
    $testsAsWarnings
  )

  Write-Host "Initializing smoke tests..."
  $webDriverDir = "$PSScriptRoot\tools\WebDriver"

  ls -Name "$webDriverDir\*.dll" |
  ForEach-Object { Add-Type -Path "$webDriverDir\$_" }

  $script:testsAsWarnings = $testsAsWarnings;

  $capabilities = New-Object OpenQA.Selenium.Remote.DesiredCapabilities
  $capabilityValue = @( "--ignore-certificate-errors")
  $capabilities.SetCapability("chrome.switches",$capabilityValue)
  $options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
  $script:driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)
  $script:driver.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(20)) | Out-Null

  $script:buildNumber = $buildNumber

  if (!$baseUrl.StartsWith("http",[System.StringComparison]::InvariantCultureIgnoreCase)) {
    $baseUrl = "http://" + $baseUrl
  }
  if (!$baseUrl.EndsWith("/")) {
    $baseUrl = $baseUrl + "/"
  }
  $script:baseUrl = $baseUrl
  $script:smokeTestResults = New-Object SmokeTestResults

  WriteWarningOrBubbleException $scriptBlockToExecute

  return $script:smokeTestResults
}

function WriteWarningOrBubbleException ([scriptblock]$testScriptToExecute) {
  try
  {
    & $testScriptToExecute
  }
  catch
  {
    if ($script:testsAsWarnings)
    {
      $theErrorMessage = $_
      Write-Warning $theErrorMessage
    }
    else
    {
      throw
    }
  }
  finally
  {
    DisposeSmokeTests
  }
}

function ExecuteCommand ($storyName,[scriptblock]$testScript) {
  $result = New-Object SmokeTestResult
  $result.StoryTitle = $storyName
  $result.Passed = $false
  try
  {
    if ($script:driver -ne $null) {
      & $testScript
    }
    $result.Passed = $true
  }
  catch {
    $result.ErrorMessage = $_
  }
  finally {
    $script:smokeTestResults.Results.Add($result)
  }
}

function DisposeSmokeTests () {
  if ($script:driver -ne $null) {
    $script:driver.Quit()
  }
}

function UrlBuilder ($path) {
  return $baseUrl + $path
}

function When ($name,[scriptblock]$fixture) {
  Write-Host "-------------------------------------------------------------"
  Write-Host $name
  Write-Host "-------------------------------------------------------------"
  ExecuteCommand $name $fixture
}


function NavigateTo ([string]$navigateTo) {
  if ($script:driver -ne $null) {
    $url = UrlBuilder $navigateTo

    Write-Host "Navigating to $url"
    $script:driver.Navigate().GoToUrl($url)
  }
}

function TypeIntoField () {
  param(
    [ValidateNotNull()]
    $fieldID,
    [ValidateNotNull()]
    $keys
  )

  if ($script:driver -ne $null) {
    Write-Host "Typing $keys into $fieldID"
    $script:driver.FindElement([OpenQA.Selenium.By]::Id($fieldID)).SendKeys($keys)
  }
}

function Click ($fieldID) {
  if ($script:driver -ne $null) {
    Write-Host "Clicking $fieldID"
    $script:driver.FindElement([OpenQA.Selenium.By]::Id($fieldID)).Click()
  }
}

function ValidateFieldExists ($fieldID) {
  if ($script:driver -ne $null) {
    if ($script:driver.FindElement([OpenQA.Selenium.By]::Id($fieldID)) -ne $null) {
      Write-Host "Validated $fieldID exists"
    }
    else {
      throw "$fieldID doesn't exist"
    }
  }
}

function ValidatePageHasTitle () {
  param(
    [Parameter(Mandatory = $true)]
    $titleToValidate
  )

  if ($script:driver -ne $null) {
    if (!($titleToValidate -ieq $script:driver.Title)) {
      throw "$($script:driver.Title) doesn't contain $titleToValidate"
    }

    Write-Host "Validated page has title $titleToValidate"
  }
}

function ValidateIsSecureRequest () {
  $currentURL = New-Object System.Uri ($script:driver.Url)
  $isSecure = ($currentURL.Scheme -ieq "https")

  if (!($isSecure)) {
    throw "$currentURL is not using HTTPS"
  }
  Write-Host "Validated request is using HTTPS"
}


