# based on:https://github.com/sergueik/Monocle/blob/develop/src/Private/Browsers.ps1
#
# create the browser via browser DriverService Class introduced in 3.1.x
# to decorate the interaction with browser Driver executable.
function launch_selenium_with_service {
  param(
    [string]$browser = '',
    [switch]$headless,
    [string]$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies',
    # Flat directory seems a better choice for Selenium dlls
    # than a subfolder-heavy C:\Windows\System32\WindowsPowerShell\v1.0\Modules
    # or ${env:LOCALAPPDATA}\Microsoft\Windows\PowerShell
    # ${env:USERPROFILE}\Downloads is popular alternative
    [string[]]$shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll',
      'nunit.core.dll',
      'Newtonsoft.Json.dll',
      'nunit.framework.dll'
    ),
    [switch]$debug
  )
  $run_headless = [bool]$PSBoundParameters['headless'].IsPresent
  if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  }

  load_shared_assemblies -shared_assemblies_path $shared_assemblies_path -shared_assemblies $shared_assemblies
  if ($browser -eq $null -or $browser -eq '') {
    throw 'Missing browser name'
  }
  [System.TimeSpan] $commandTimeout = [System.TimeSpan]::FromSeconds(60) # will apply to all commands
  if ($browser -match 'firefox') {
    $options = [OpenQA.Selenium.Firefox.FirefoxOptions]::new()
    if ($run_headless ) {
       $options.AddArguments('-headless')
    }
    # https://selenium.dev/selenium/docs/api/dotnet/html/T_OpenQA_Selenium_Firefox_FirefoxDriverService.htm
    [OpenQA.Selenium.Firefox.FirefoxDriverService]$service = [OpenQA.Selenium.Firefox.FirefoxDriverService]::CreateDefaultService($shared_assemblies_path)
    $service.HideCommandPromptWindow = $true
    $service.SuppressInitialDiagnosticInformation = $true
    # https://selenium.dev/selenium/docs/api/dotnet/html/T_OpenQA_Selenium_Firefox_FirefoxDriver.htm
    # Initializes FirefoxDriver the constructor accepting parameters:
    # options
    # driver service
    # timeout.
    # Use Marionette driver implementation.
    $selenium = [OpenQA.Selenium.Firefox.FirefoxDriver]::new($service, $options, $commandTimeout)
  } elseif ($browser -match 'chrome') {
    # https://selenium.dev/selenium/docs/api/dotnet/html/T_OpenQA_Selenium_Chrome_ChromeDriverService.htm
    [OpenQA.Selenium.Chrome.ChromeDriverService]$service = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($shared_assemblies_path)
    [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
    # alternatively call
    [OpenQA.Selenium.Chrome.ChromeOptions]$options = [OpenQA.Selenium.Chrome.ChromeOptions]::new()

    # add arguments
    @(
    '-no-first-run',
    '-no-default-browser-check',
    '-disable-default-apps',
    '-no-sandbox',
    '-disable-dev-shm-usage',

    ) | sort-object -unique | forEach-object {
       $argument = $_
       $options.AddArguments($argument)
    }
    if ($run_headless ) {
       $options.AddArguments('-headless')
    }
    $service.HideCommandPromptWindow = $true
    $service.SuppressInitialDiagnosticInformation = $true
    # https://selenium.dev/selenium/docs/api/dotnet/html/M_OpenQA_Selenium_Chrome_ChromeDriver__ctor_3.htm		
    $selenium = new-object [OpenQA.Selenium.Chrome.ChromeDriver]($service, $options, $commandTimeout)

  } else {
    throw ( 'Unrecognized browser {0}' -f $browser )
  }

}

