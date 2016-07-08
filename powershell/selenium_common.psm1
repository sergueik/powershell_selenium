
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

function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}

<#
.SYNOPSIS
	Start Selenium
.DESCRIPTION
	Start Selenium
	
.EXAMPLE
    $selenium = launch_selenium -browser 'chrome' -hub_host -hub_port
    Will launch the selenium java hub and slave locally
.LINK

	
.NOTES
	VERSION HISTORY
	2015/06/07 Initial Version
#>
function launch_selenium {
  param(
    [string]$browser = '',
    [switch]$grid,
    [int]$version,
    [string]$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies',
    [string[]]$shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll',
      'nunit.core.dll',
      'Newtonsoft.Json.dll',
      'nunit.framework.dll'
    ),
    [string]$hub_host = '127.0.0.1',
    [string]$hub_port = '4444',
    [bool]$use_remote_driver = $false,
    [switch]$debug
  )

  # Write-Debug (Get-ScriptDirectory)
  $use_remote_driver = [bool]$PSBoundParameters['grid'].IsPresent
  $phantomjs_path = 'C:\tools\phantomjs\bin'
  if (($env:PHANTOMJS_PATH -ne $null) -and ($env:PHANTOMJS_PATH -ne '')) {
    $phantomjs_path = $env:PHANTOMJS_PATH
  }

  $selenium_path =  'c:\java\selenium' 
  if (($env:SELENIUM_PATH -ne $null) -and ($env:SELENIUM_PATH -ne '')) {
    $selenium_path = $env:SELENIUM_PATH
  }

  # SHARED_ASSEMBLIES_PATH environment overrides parameter, for Team City
  if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  }

  $driver_folder_path = 'c:\java\selenium'
  # SELENIUM_DRIVERS_PATH environment overrides parameter, for Team City
  if (($env:SELENIUM_DRIVERS_PATH -ne $null) -and ($env:SELENIUM_DRIVERS_PATH -ne '')) {
    $driver_folder_path = $env:SELENIUM_DRIVERS_PATH
  }
  # write-Debug "load_shared_assemblies -shared_assemblies_path ${shared_assemblies_path} -shared_assemblies ${shared_assemblies}"
  # start-sleep -milliseconds 1000
  load_shared_assemblies -shared_assemblies_path $shared_assemblies_path -shared_assemblies $shared_assemblies
<#
  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    if ($host.Version.Major -gt 2) {
      Unblock-File -Path $_
    }
    Write-Debug $_
    Add-Type -Path $_
  }
  popd
#>

  $uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))
  if ($DebugPreference -eq 'Continue') {
    if ($use_remote_driver) {
      Write-Host 'Using remote driver'
    } else {
      Write-Host 'Using standalone driver'
    }
  }

  $selenium = $null
  if ($browser -ne $null -and $browser -ne '') {
    if ($use_remote_driver) {

      try {
        $connection = (New-Object Net.Sockets.TcpClient)
        $connection.Connect($hub_host,[int]$hub_port)
        Write-Debug 'Grid is already running'

        $connection.Close()
      } catch {
        Write-Debug 'Launching grid'
        Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selenium_path}\hub.cmd"
        Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selenium_path}\node.cmd"
        Start-Sleep -Millisecond 5000
      }

    } else {
      # launching Selenium jar in  standalone is not needed

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
    }


    Write-Debug "Launching ${browser}"

    if ($browser -match 'firefox') {
      if ($use_remote_driver) {

        $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
        $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)

      } else {

        #  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

        [object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager

        [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)
        [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile)
        $selected_profile_object.setPreference('general.useragent.override',"Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/34.0")

        # https://code.google.com/p/selenium/issues/detail?id=40

        $selected_profile_object.setPreference("browser.cache.disk.enable", $false)
        $selected_profile_object.setPreference("browser.cache.memory.enable", $false)
        $selected_profile_object.setPreference("browser.cache.offline.enable", $false)
        $selected_profile_object.setPreference("network.http.use-cache", $false)

        $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($selected_profile_object)
        [OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

        # [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
        # [NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')
      }
    }
    elseif ($browser -match 'chrome') {

      if ($use_remote_driver) {
        $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
        $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
      } else {
        # TODO: path to  chromedriver.exe

        # override

        # Oveview of extensions 
        # https://sites.google.com/a/chromium.org/chromedriver/capabilities

        $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
        # Profile creation
        # https://support.google.com/chrome/answer/142059?hl=en
        # http://www.labnol.org/software/create-family-profiles-in-google-chrome/4394/
        # using Profile 
        # http://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile/377195#377195


        # origin:
        # http://stackoverflow.com/questions/20401264/how-to-access-network-panel-on-google-chrome-developer-toools-with-selenium

        [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions

        $options.addArguments('start-maximized')
        # no-op option - re-enforcing the default setting
        $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\','/')))
        # if you like to specify another profile parent directory:
        # $options.addArguments('user-data-dir=c:/TEMP'); 

        $options.addArguments('--profile-directory=Default')

        [OpenQA.Selenium.Remote.DesiredCapabilities]$capabilities = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
        $capabilities.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability,$options)

        $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)
      }



    }
    elseif ($browser -match 'ie') {
      if ($use_remote_driver) {
        $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
        if ($version -ne $null -and $version -ne 0) {
          $capability.setCapability('version',$version.ToString());
        }

        # $capability.setCapability(InternetExplorerDriver.ENABLE_ELEMENT_CACHE_CLEANUP, true)
        # $capability.setCapability(InternetExplorerDriver.IE_ENSURE_CLEAN_SESSION, $true)
        $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
      } else {
        <#
NOTE:
New-Object : Exception calling ".ctor" with "1" argument(s): "Unexpected error launching Internet Explorer. Browser zoom level was set to 75%. It should be
#>
        $selenium = New-Object OpenQA.Selenium.IE.InternetExplorerDriver ($driver_folder_path)
      }
    }
    elseif ($browser -match 'safari') {
      # TODO: throw exception if not provided the 'grid' switch
      $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()

      $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
    }
    else {
      throw "unknown browser choice:${browser}"
    }
  } else {
    $phantomjs_useragent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34'
    Write-Host 'Running on phantomjs'
    $headless = $true
    if (-not (Test-Path -Path $phantomjs_path)) {
      throw 'Missing PhantomJS'
    }
    $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_path)
    $selenium.Capabilities.setCapability('ssl-protocol','any')
    $selenium.Capabilities.setCapability('ignore-ssl-errors',$true)
    $selenium.Capabilities.setCapability('takesScreenshot',$true)
    $selenium.Capabilities.setCapability('userAgent',$phantomjs_useragent)
    $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
    $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_path)
  }

  return $selenium
}

<#
.SYNOPSIS
	Stops Selenium
.DESCRIPTION
	Stops Selenium
	
.EXAMPLE
    cleanup ([ref]$selenium)
    Will tell selenium to stop the browser window 
.LINK
	
	
.NOTES

	VERSION HISTORY
	2015/06/07 Initial Version
#>


function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Close()
    $selenium_ref.Value.Quit()
  } catch [exception]{
    # Ignore errors if unable to close the browser
    Write-Output (($_.Exception.Message) -split "`n")[0]

  }
}

<#
.SYNOPSIS
	Pauses the Selenium execution
.DESCRIPTION
	Pauses the Selenium execution
	
.EXAMPLE
	custom_pause [-fullstop]
    
.LINK
	
	
.NOTES

	VERSION HISTORY
	2015/06/21 Initial Version
#>


function custom_pause {
  param([bool]$fullstop)
  # Do not close Browser / Selenium when run from Powershell ISE
  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }
}



<#
.SYNOPSIS
	Sets default timeouts with current Selenium session
.DESCRIPTION
	Sets default timeouts with current Selenium session
	
.EXAMPLE
    set_timeouts ([ref]$selenium) [-exlicit <explicit timeout>] [-page_load <page load timeout>] [-script <script timeout>]
    
.LINK
	
	
.NOTES

	VERSION HISTORY
	2015/06/21 Initial Version
#>


function set_timeouts {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [int]$explicit = 60,
    [int]$page_load = 60,
    [int]$script = 60
  )

  [void]($selenium_ref.Value.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))
  [void]($selenium_ref.Value.Manage().timeouts().SetPageLoadTimeout([System.TimeSpan]::FromSeconds($pageload)))
  [void]($selenium_ref.Value.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script)))

}


<#
.SYNOPSIS
	Loads calller-provided list of .net assembly dlls or fails with a custom exception
	
.DESCRIPTION
	Loads calller-provided list of .net assembly dlls or fails with a custom exception    
.EXAMPLE
	load_shared_assemblies -shared_assemblies_path 'c:\tools' -shared_assemblies @('WebDriver.dll','WebDriver.Support.dll','nunit.framework.dll')
.LINK 
	
	
.NOTES

	VERSION HISTORY
	2015/06/22 Initial Version
#>

function load_shared_assemblies {

  param(
    [string]$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies',

    [string[]]$shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll',
      'Newtonsoft.Json.dll',
      'nunit.core.dll',
      'nunit.framework.dll'
      )
  )


  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    Write-Debug ('Loading {0} ' -f $_)
    Unblock-File -Path $_;
    Add-Type -Path $_ }
  popd
}


<#
.SYNOPSIS
	Loads calller-provided list of .net assembly dlls with specific versions or fails with a custom exception
.DESCRIPTION
	Loads calller-provided list of .net assembly dlls with specific versions or fails with a custom exception
	
.EXAMPLE
	load_shared_assemblues_demand_versions -shared_assemblies_path 'c:\tools'    
.LINK
	
	
.NOTES

	VERSION HISTORY
	2015/06/22 Initial Version
#>

function load_shared_assemblues_demand_versions {
  param(
    [string]$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies',
    $shared_assemblies = @{
      'WebDriver.dll' = 2.47;
      'WebDriver.Support.dll' = '2.47';
      'nunit.core.dll' = $null;
      'nunit.framework.dll' = $null;
      'Newtonsoft.Json.dll' = $null; 
    }
  )

  pushd $shared_assemblies_path
  $shared_assemblies.Keys | ForEach-Object {
    # http://all-things-pure.blogspot.com/2009/09/assembly-version-file-version-product.html
    $assembly = $_
    $assembly_path = [System.IO.Path]::Combine($shared_assemblies_path,$assembly)
    $assembly_version = [Reflection.AssemblyName]::GetAssemblyName($assembly_path).Version
    $assembly_version_string = ('{0}.{1}' -f $assembly_version.Major,$assembly_version.Minor)
    if ($shared_assemblies[$assembly] -ne $null) {

      if (-not ($shared_assemblies[$assembly] -match $assembly_version_string)) {
        Write-Output ('Need {0} {1}, got {2}' -f $assembly,$shared_assemblies[$assembly],$assembly_path)
        Write-Output $assembly_version
        throw ('invalid version :{0}' -f $assembly)
      }
    }

    if ($host.Version.Major -gt 2) {
      Unblock-File -Path $_;
    }
    Write-Debug $_
    Add-Type -Path $_
  }
  popd


}


# TODO: local connections only ?
function netstat_check {
  param(
    [string]$selenium_http_port = 4444
  )

  $local_tcpconnections = Invoke-Expression -Command ("C:\Windows\System32\netsh.exe interface ipv4 show tcpconnections localport={0}" -f $selenium_http_port)

  $established_tcpconnections = $local_tcpconnections | Where-Object { ($_ -match '\bEstablished\b') }
  (($established_tcpconnections -ne '') -and $established_tcpconnections -ne $null)

}


<#
findstr /ic:"`$selenium " *.ps1
#>


<#
.SYNOPSIS
	Common method to read installed program installlocation information
.DESCRIPTION
	
	
.EXAMPLE
	$sqlite_installlocation_path = read_registry -registry_path '/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/' -package_name 'System.Data.SQLite'
	$sqlite_assemblies_path = [System.IO.Path]::Combine($sqlite_installlocation_path,'bin')
.LINK
	
	
.NOTES

	VERSION HISTORY
	2015/07/25 Initial Version
#>

function read_installed_programs_registry {
  param([string]$registry_path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/',
    [string]$registry_hive = 'HKLM:',
    [string]$package_name
  )

  $install_location = $null

  pushd $registry_hive

  cd $registry_path
  $apps = Get-ChildItem -Path .

  $apps | ForEach-Object {
    # https://msdn.microsoft.com/en-us/library/microsoft.win32.registrykey%28v=vs.110%29.aspx
    $registry_key = $_
    $registry_key_path = ($registry_key.ToString()) -replace '^.+\\','.\'
    $values = $registry_key.GetValueNames()

    if (-not ($values.GetType().BaseType.Name -match 'Array')) {
      popd
      throw 'Unexpected result type'
    }


    $values | Where-Object { $_ -match '^DisplayName$' } | ForEach-Object {

      try {
        $displayname_result = $registry_key.GetValue($_).ToString()

      } catch [exception]{
        Write-Debug $_
      }

      if ($displayname_result -ne $null -and $displayname_result -match "\b${package_name}\b") {

        Write-Host -foreground 'blue' $registry_key_path

        $pachage_information = $registry_key.GetValueNames()
        $install_location = $null
        $pachage_information | Where-Object { $_ -match '\bInstallLocation\b' } | ForEach-Object {
          $install_location = $registry_key.GetValue($_).ToString()
          Write-Host -ForegroundColor 'yellow' (($displayname_result,$registry_key.Name,$install_location) -join "`r`n")
        }
      }
    }
  }
  popd
  return $install_location
}

