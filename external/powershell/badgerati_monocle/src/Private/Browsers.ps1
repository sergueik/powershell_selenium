function Get-MonocleBrowserPath


{
 param(
[string]$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies',
  [string[]]$shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll',
      'nunit.core.dll',
      'Newtonsoft.Json.dll',
      'nunit.framework.dll'
    ),
        [switch]$debug
)
return $shared_assemblies_path;
# the below should be ignored - it keeps everything in the project

  # SELENIUM_DRIVERS_PATH environment overrides parameter, for Team City
  $selenium_path =  'c:\java\selenium'
  if (($env:SELENIUM_PATH -ne $null) -and ($env:SELENIUM_PATH -ne '')) {
    $selenium_path = $env:SELENIUM_PATH
  }

  # SHARED_ASSEMBLIES_PATH environment overrides parameter, for Team City/Jenkinks
  if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  }

  $selenium_drivers_path = 'c:\java\selenium'
  # SELENIUM_DRIVERS_PATH environment overrides parameter, for Team City/Jenkinks
  if (($env:SELENIUM_DRIVERS_PATH -ne $null) -and ($env:SELENIUM_DRIVERS_PATH -ne '')) {
    $selenium_drivers_path = $env:SELENIUM_DRIVERS_PATH
  } elseif (($env:SELENIUM_PATH -ne $null) -and ($env:SELENIUM_PATH -ne '')) {
    $selenium_drivers_path = $env:SELENIUM_PATH
  }

  # write-debug "load_shared_assemblies -shared_assemblies_path ${shared_assemblies_path} -shared_assemblies ${shared_assemblies}"
  # start-sleep -milliseconds 1000
  load_shared_assemblies -shared_assemblies_path $shared_assemblies_path -shared_assemblies $shared_assemblies

return
    $root = (Split-Path -Parent -Path $PSScriptRoot)
    $root = (Join-Path $root 'lib')
    $root = (Join-Path $root 'Browsers')

    $os = 'win'
    $chmod = $false

    if ($IsLinux) {
        $os = 'linux'
        $chmod = $true
    }
    elseif ($IsMacOS) {
        $os = 'mac'
        $chmod = $true
    }

    $path = (Join-Path $root $os)

    if ($chmod) {
        Get-ChildItem -Path $path -Force -File | ForEach-Object {
            chmod +x $_.FullName | Out-Null
        }
    }

    return $path
}

function Initialize-MonocleBrowser
{
    param(
        [Parameter()]
        [string]
        $Type,

        [Parameter()]
        [string[]]
        $Arguments,

        [switch]
        $Hide
    )

    if ([string]::IsNullOrWhiteSpace($Type)) {
        $Type = 'IE'
        if ($IsLinux -or $IsMacOS) {
            $Type = 'Chrome'
        }
    }

    switch ($Type.ToLowerInvariant()) {
        'ie' {
            return Initialize-MonocleIEBrowser -Arguments $Arguments -Hide:$Hide
        }

        'chrome' {
            return Initialize-MonocleChromeBrowser -Arguments $Arguments -Hide:$Hide
        }

        'firefox' {
            return Initialize-MonocleFirefoxBrowser -Arguments $Arguments -Hide:$Hide
        }

        default {
            throw "No browser for $($Type)"
        }
    }
}

function Initialize-MonocleIEBrowser
{
    param(
        [Parameter()]
        [string[]]
        $Arguments,

        [switch]
        $Hide
    )

    $options = [OpenQA.Selenium.IE.InternetExplorerOptions]::new()
    if ($null -eq $Arguments) {
        $Arguments = @()
    }

    $options.RequireWindowFocus = $false
    $options.IgnoreZoomLevel = $true

    # add arguments
    $Arguments | Sort-Object -Unique | ForEach-Object {
        $options.AddArguments($_.TrimStart('-'))
    }

    # create the browser
    $service = [OpenQA.Selenium.IE.InternetExplorerDriverService]::CreateDefaultService((Get-MonocleBrowserPath))
    $service.HideCommandPromptWindow = $true
    $service.SuppressInitialDiagnosticInformation = $true

    return [OpenQA.Selenium.IE.InternetExplorerDriver]::new($service, $options)
}

function Initialize-MonocleChromeBrowser
{
    param(
        [Parameter()]
        [string[]]
        $Arguments,

        [switch]
        $Hide
    )

    $options = [OpenQA.Selenium.Chrome.ChromeOptions]::new()
    if ($null -eq $Arguments) {
        $Arguments = @()
    }

    # needed to prevent general issues
    $Arguments += 'no-first-run'
    $Arguments += 'no-default-browser-check'
    $Arguments += 'disable-default-apps'

    # these are needed to allow running in a container
    $Arguments += 'no-sandbox'
    $Arguments += 'disable-dev-shm-usage'

    # hide the browser?
    if ($Hide -or ($env:MONOCLE_HEADLESS -ieq '1')) {
        $Arguments += 'headless'
    }

    # add arguments
    $Arguments | Sort-Object -Unique | ForEach-Object {
        $options.AddArguments($_.TrimStart('-'))
    }

    # create the browser
    $service = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService((Get-MonocleBrowserPath))
    $service.HideCommandPromptWindow = $true
    $service.SuppressInitialDiagnosticInformation = $true

    return [OpenQA.Selenium.Chrome.ChromeDriver]::new($service, $options)
}

function Initialize-MonocleFirefoxBrowser
{
    param(
        [Parameter()]
        [string[]]
        $Arguments,

        [switch]
        $Hide
    )

    $options = [OpenQA.Selenium.Firefox.FirefoxOptions]::new()
    if ($null -eq $Arguments) {
        $Arguments = @()
    }

    # hide the browser?
    if ($Hide -or ($env:MONOCLE_HEADLESS -ieq '1')) {
        $Arguments += 'headless'
    }

    # add arguments
    $Arguments | Sort-Object -Unique | ForEach-Object {
        $options.AddArguments("-$($_.TrimStart('-'))")
    }

    # create the browser
    $service = [OpenQA.Selenium.Firefox.FirefoxDriverService]::CreateDefaultService((Get-MonocleBrowserPath))
    $service.HideCommandPromptWindow = $true
    $service.SuppressInitialDiagnosticInformation = $true

    return [OpenQA.Selenium.Firefox.FirefoxDriver]::new($service, $options, [timespan]::FromSeconds(60))
}
