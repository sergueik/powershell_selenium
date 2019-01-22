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
function Get-ScriptDirectory
{
  [string]$scriptDirectory = $null

  if ($host.Version.Major -gt 2) {
    $scriptDirectory = (Get-Variable PSScriptRoot).Value
    Write-Debug ('$PSScriptRoot: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
    Write-Debug ('$MyInvocation.PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    Write-Debug ('$PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
  } else {
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSScriptRoot) {
      $scriptDirectory = $Invocation.PSScriptRoot
    } elseif ($Invocation.MyCommand.Path) {
      $scriptDirectory = Split-Path $Invocation.MyCommand.Path
    } else {
      $scriptDirectory = $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))
    }
    return $scriptDirectory
  }
}

<#
.SYNOPSIS
	Start Selenium
.DESCRIPTION
	Start Selenium
	
.EXAMPLE
    $selenium = launch_selenium -browser 'chrome' -hub_host -hub_port
    Will launch the selenium java hub and slave locally using batch commands or will connect to remote host and port
    $selenium = launch_selenium -browser 'chrome' -headless
    Will launch chrome in headless mode via the selenium driver, chromedriver
.LINK

	
.NOTES
	VERSION HISTORY
	2015/06/07 Initial Version
  ... misc untracted updates
	2018/07/26 added Headless support (only tested with Chrome))
#>
function launch_selenium {
  param(
    [string]$browser = '',
    [switch]$grid,
    [switch]$headless,
    [int]$version,
    [string]$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies',
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
  # Write-Debug (Get-ScriptDirectory)
  $run_headless = [bool]$PSBoundParameters['headless'].IsPresent
  if ($run_headless) {
    write-debug 'launch_selenium: Running headless'
  }
  $phantomjs_path = 'C:\tools\phantomjs\bin'
  if (($env:PHANTOMJS_PATH -ne $null) -and ($env:PHANTOMJS_PATH -ne '')) {
    $phantomjs_path = $env:PHANTOMJS_PATH
  }

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
        Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -argumentList "start cmd.exe /c ${selenium_path}\hub.cmd"
        Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -argumentList "start cmd.exe /c ${selenium_path}\node.cmd"
        Start-Sleep -Millisecond 5000
      }

    } else {
      # launching Selenium jar in standalone execution is not needed

      # adding driver folder to the path environment
      if (-not (Test-Path $selenium_drivers_path)) {
        throw "Folder ${selenium_drivers_path} does not exist, cannot be added to $env:PATH"
      }

      # See if the new folder is already in the path.
      if ($env:PATH | Select-String -SimpleMatch $selenium_drivers_path)
      { Write-Debug "Folder ${selenium_drivers_path} already within `$env:PATH"

      }

      # Set the new PATH environment
      $env:PATH = $env:PATH + ';' + $selenium_drivers_path
    }

<#

$debugpreference='continue'
$browser_versions = @{}
@(
'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' ,
'C:\Program Files (x86)\Mozilla Firefox\firefox.exe' ,
'C:\Program Files\Internet Explorer\iexplore.exe'
) | foreach-object {
  $application_path = $_
  write-debug ('Probing "{0}"' -f $application_path)
  $versiondata = get-item -path $application_path | select-object -expandproperty VersionInfo| select-object -property ProductVersion
  $version = $versiondata.ProductVersion
  write-debug ('Version: {0}' -f $version)
  $browser_versions[($application_path -replace '^.*\\', '')] = $version
}
write-output $browser_versions


Note : Powershell image `ProductVersion` property is ony useful with IEDriverServer:
pushd $selenium_path
get-item -path IEDriverServer.exe | select-object -expandproperty VersionInfo| select-object -property ProductVersion

ProductVersion
--------------
3.1.0.0

There is no way to determine the chromedriver.exe or geckodriver.exe version by similar command

pushd $selenium_path
format-list -inputobject (get-item -path chromedriver.exe| select-object -expandproperty VersionInfo )

OriginalFilename  :
FileDescription   :
ProductName       :
Comments          :
CompanyName       :
FileName          : C:\java\selenium\chromedriver.exe
FileVersion       :
ProductVersion    :
IsDebug           : False
IsPatched         : False
IsPreRelease      : False
IsPrivateBuild    : False
IsSpecialBuild    : False
Language          :
LegalCopyright    :
LegalTrademarks   :
PrivateBuild      :
SpecialBuild      :
FileVersionRaw    : 0.0.0.0
ProductVersionRaw : 0.0.0.0

The uniform way is to call the driver


$options = @{
  'IEDriverServer.exe' = '/version';
  'Chromedriver.exe' = '/version' ;
  'geckodriver.exe' ='-V';
}

foreach ($o in $options.GetEnumerator()) {
  $application = $o.Key
  $commandline_flags = $o.Value
  (& "${selenium_path}\${application}" $commandline_flags ) | tee-object -variable cmdline_output
  write-debug ($cmdline_output -join '' )
  # TODO: case insenitive match
  $capture_expression = ('{0}(?:\.exe)* (?<version>\d+\.\d+\.\d+(?:\.\d+)*)\b .*' -f ($application -replace '.exe$', ''))
  # $capture_expression = 'geckodriver (?<version>\d\.\d+\.\d)'
  write-debug $capture_expression
  [System.Text.RegularExpressions.MatchCollection]$match_collection = [System.Text.RegularExpressions.Regex]::Matches($cmdline_output, $capture_expression)
  write-debug $match_collection.Groups[1].Value
}

(& "${selenium_path}\IEDriverServer.exe" '/version' ) | tee-object -variable iedriver_version
IEDriverServer.exe 3.1.0.0 (64-bit)

(& "${selenium_path}\chromedriver.exe" '/version' ) | tee-object -variable chromedriver_version
ChromeDriver 2.40.565498 (ea082db3280dd6843ebfb08a625e3eb905c4f5ab)

(& "${selenium_path}\geckodriver.exe" '-V' ) | tee-object -variable geckodriver_version_command_output
geckodriver 0.15.0

The source code of this program is available at
https://github.com/mozilla/geckodriver.

[System.Text.RegularExpressions.MatchCollection]$match_collection = [System.Text.RegularExpressions.Regex]::Matches($geckodriver_version_command_output, 'geckodriver (?<version>\d\.\d+\.\d)')
$match_collection.Groups[1].Value

which can be collaptsed into
([System.Text.RegularExpressions.Regex]::Matches($geckodriver_version_command_output, 'geckodriver (?<version>\d\.\d+\.\d)')).Groups[1].Value
#>
    write-debug "Launching ${browser}"

    if ($browser -match 'firefox') {
      if ($use_remote_driver) {
        $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
        $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)

      } else {
        # Need constructior with firefoxOptions for headless
        if ($run_headless) {
          # https://stackoverflow.com/questions/46848615/headless-firefox-in-selenium-c-sharp
          [OpenQA.Selenium.Firefox.FirefoxOptions]$firefox_options = new-object OpenQA.Selenium.Firefox.FirefoxOptions
          $firefox_options.addArguments('--headless')
          $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($firefox_options)
        } else {
          $driver_environment_variable = 'webdriver.gecko.driver'
          if (-not [Environment]::GetEnvironmentVariable($driver_environment_variable, [System.EnvironmentVariableTarget]::Machine)){
            [Environment]::SetEnvironmentVariable( $driver_environment_variable, "${selenium_drivers_path}\geckodriver.exe")
          }
          #  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

          [object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager

          [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)
          [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile)
          $selected_profile_object.setPreference('general.useragent.override',"Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/34.0")

          # https://code.google.com/p/selenium/issues/detail?id=40

          $selected_profile_object.setPreference('browser.cache.disk.enable', $false)
          $selected_profile_object.setPreference('browser.cache.memory.enable', $false)
          $selected_profile_object.setPreference('browser.cache.offline.enable', $false)
          $selected_profile_object.setPreference('network.http.use-cache', $false)

          $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($selected_profile_object)
          [OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

          # [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
          # [NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')
        }
      }
    }
    elseif ($browser -match 'chrome') {
      $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
      if ($use_remote_driver) {
        $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
      } else {
        $driver_environment_variable = 'webdriver.chrome.driver'
        if (-not [Environment]::GetEnvironmentVariable($driver_environment_variable, [System.EnvironmentVariableTarget]::Machine)){
          [Environment]::SetEnvironmentVariable( $driver_environment_variable, "${selenium_drivers_path}\chromedriver.exe")
        }

        # override

        # Oveview of extensions
        # https://sites.google.com/a/chromium.org/chromedriver/capabilities

        # Profile creation
        # https://support.google.com/chrome/answer/142059?hl=en
        # http://www.labnol.org/software/create-family-profiles-in-google-chrome/4394/
        # using Profile
        # http://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile/377195#377195


        # origin:
        # http://stackoverflow.com/questions/20401264/how-to-access-network-panel-on-google-chrome-developer-toools-with-selenium

        [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions

        if ($run_headless) {
          $width = 1200;
          $height = 800;
          # https://stackoverflow.com/questions/45130993/how-to-start-chromedriver-in-headless-mode
          $options.addArguments([System.Collections.Generic.List[string]]@('--headless',"--window-size=${width}x${height}", '-disable-gpu'))
        } else {
	# TODO: makse configurable through a switch 
       #   $options.addArguments('start-maximized')
          # no-op option - re-enforcing the default setting
          $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\','/')))
          # if you like to specify another profile parent directory:
          # $options.addArguments('user-data-dir=c:/TEMP');

          $options.addArguments('--profile-directory=Default')

          [OpenQA.Selenium.Remote.DesiredCapabilities]$capabilities = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
          $capabilities.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability,$options)
        }
        $locale = 'en-us'
        # http://knowledgevault-sharing.blogspot.com/2017/05/selenium-webdriver-with-powershell.html
        $options.addArguments([System.Collections.Generic.List[string]]@('--allow-running-insecure-content', '--disable-infobars', '--enable-automation', '--kiosk', "--lang=${locale}"))
        $options.AddUserProfilePreference('credentials_enable_service', $false)
        $options.AddUserProfilePreference('profile.password_manager_enabled', $false)
        $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver($options)
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
        $driver_environment_variable = 'webdriver.ie.driver'
        if (-not [Environment]::GetEnvironmentVariable($driver_environment_variable, [System.EnvironmentVariableTarget]::Machine)){
          [Environment]::SetEnvironmentVariable( $driver_environment_variable, "${selenium_drivers_path}\chromedriver.exe")
        }
        $selenium = New-Object OpenQA.Selenium.IE.InternetExplorerDriver($selenium_drivers_path)
      }
    }
    elseif ($browser -match 'safari') {
      $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()

      $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
    }
    else {
      throw "unknown browser choice:${browser}"
    }
  } else {
    $phantomjs_useragent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34'
    Write-Host 'Running on phantomjs'
    $run_headless = $true
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


function cleanup {
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
    [string]$shared_assemblies_path = 'C:\java\selenium\csharp\sharedassemblies',
    [string[]]$shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll',
      'Newtonsoft.Json.dll',
      'nunit.core.dll',
      'nunit.framework.dll'
      )
  )

  Write-Debug ('Loading "{0}" from ' -f ($shared_assemblies -join ',' ), $shared_assemblies_path)
  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    $shared_assembly_filename = $_
    if ( assembly_is_loaded -assembly_path ("${shared_assemblies_path}\\{0}" -f $shared_assembly_filename)) {
      write-debug ('Skipping from  assembly "{0}"' -f $shared_assembly_filename)
     } else {
      write-debug ('Loading assembly "{0}" ' -f $shared_assembly_filename)
      Unblock-File -Path $shared_assembly_filename;
      Add-Type -Path $shared_assembly_filename
    }
  }
  popd
}

<#
.SYNOPSIS
	Loads caller-specified list of .net assembly dll/ versions.
.DESCRIPTION
	Loads caller-specified list of .net assembly dll/ versions.
  Fails with a custom exception when a paricular assembly is of the wrong version
	
.EXAMPLE
	load_shared_assemblies_with_versions -shared_assemblies_path 'c:\tools'
.LINK
	
	
.NOTES

	VERSION HISTORY
	2015/06/22 Initial Version
#>
function load_shared_assemblies_with_versions {
  param(
    [string]$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies',
    $shared_assemblies = @{
      'WebDriver.dll'         = '2.53';
      'WebDriver.Support.dll' = '2.53';
      'nunit.core.dll'        = $null;
      'nunit.framework.dll'   = $null;
      'Newtonsoft.Json.dll'   = $null;
    }
  )

  pushd $shared_assemblies_path
  $shared_assemblies.Keys | ForEach-Object {
    # http://all-things-pure.blogspot.com/2009/09/assembly-version-file-version-product.html
    $shared_assembly_filename = $_
    $shared_assembly_pathname = [System.IO.Path]::Combine($shared_assemblies_path,$shared_assembly_filename)
    $assembly_version = [Reflection.AssemblyName]::GetAssemblyName($shared_assembly_pathname).Version
    $assembly_version_string = ('{0}.{1}' -f $assembly_version.Major,$assembly_version.Minor)
    if ($shared_assemblies[$shared_assembly_filename] -ne $null) {

      if (-not ($shared_assemblies[$shared_assembly_filename] -match $assembly_version_string)) {
        Write-Output ('Need version {0} of {1} - got {2} in {3}' -f $shared_assemblies[$shared_assembly_filename], $shared_assembly_filename, ( '{0}.{1}.{2}' -f $assembly_version.'Major', $assembly_version.'Minor', $assembly_version.'Build' ), $assembly_path)
        Write-Output $assembly_version
        popd
        throw ('Invalid version of assembly: {0}' -f $shared_assembly_filename)
      }
    }

    if ($host.Version.Major -gt 2) {
      Unblock-File -Path $shared_assembly_filename;
    }
    Write-Debug $shared_assembly_filename
    Add-Type -Path $shared_assembly_filename
  }
  popd


}


# TODO: local connections only ?
function netstat_check {
  param(
    [string]$selenium_http_port = 4444
  )

  $local_tcpconnections = Invoke-Expression -Command ('C:\Windows\System32\netsh.exe interface ipv4 show tcpconnections localport={0}' -f $selenium_http_port)

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


<#
.SYNOPSIS
	Common method to perform assertions
.DESCRIPTION
	Based on: https://gallery.technet.microsoft.com/scriptcenter/A-PowerShell-Assert-d383bf14
	With pipeline support removed
		
.EXAMPLE
		assert_true (1 -eq 0)
.NOTES
	VERSION HISTORY
	2018/07/05 Initial Version
#>

function assert_true {
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $false,Position = 0)]
    [AllowNull()]
    [AllowEmptyCollection()]
    [System.Object]
    $InputObject
  )

  $info = '{0}, file {1}, line {2}' -f @( $MyInvocation.Line.Trim(),$MyInvocation.ScriptName,$MyInvocation.ScriptLineNumber)
  if ($null -eq $InputObject) {
    $message = "Assertion failed: $info"
    Write-Debug -Message $message
    if (-not ($debugpreference -match 'continue')) {
      throw $message
    } else {
      Write-Debug -Message 'Continue'
    }
  }
  if (($InputObject -isnot [System.Boolean]) -and ($InputObject -isnot $null)) {
    $type = $InputObject.GetType().FullName
    $value = if ($InputObject -is [System.String]) { "'$InputObject'" } else { "{$InputObject}" }
    $message = "Assertion failed (`$InputObject is of type $type with value $value): $info"
    Write-Debug -Message $message
    if (-not ($debugpreference -match 'continue')) {
      throw $message
    } else {
      Write-Debug -Message 'Continue'
    }
  }
  if (($InputObject -is [System.Boolean]) -and (-not $InputObject)) {
    $message = "Assertion failed: $info"
    Write-Debug -Message $message
    if (-not ($debugpreference -match 'continue')) {
      throw $message
    } else {
      Write-Debug -Message 'Continue'
    }
  }
  Write-Verbose -Message "Assertion passed: $info"
}

# based on https://github.com/PowerShellCrack/AdminRunasMenu/blob/master/App/AdminMenu.ps1
# dealing with cache:
# inspect if the assembly is already loaded:

function assembly_is_loaded{
  param(
    [string[]]$defined_type_names = @(),
    [string]$assembly_path
  )

  $loaded_project_specific_assemblies = @()
  $loaded_defined_type_names = @()

  if ($defined_type_names.count -ne 0) {
    $loaded_defined_type_names = [appdomain]::currentdomain.getassemblies() |
        where-object {$_.location -eq ''} |
        select-object -expandproperty DefinedTypes |
        select-object -property Name
    # TODO: return if any of the types from Add-type is already there
    return ($loaded_defined_type_names -contains $defined_type_names[0])
  }

  if ($assembly_path -ne $null) {
    [string]$check_assembly_path = ($assembly_path -replace '\\\\' , '/' ) -replace '/', '\'
    # NOTE: the location property may both be $null or an empty string
    $loaded_project_specific_assemblies =
    [appdomain]::currentdomain.getassemblies() |
      where-object {$_.GlobalAssemblyCache -eq $false -and $_.Location -match '\S' } |
      select-object -expandproperty Location
      # write-debug ('Check if loaded: {0} {1}' -f $check_assembly_path,$assembly_path)
    write-debug ("Loaded asseblies:  {0}" -f $loaded_project_specific_assemblies.count)
    if ($DebugPreference -eq 'Continue') {
     if (($loaded_project_specific_assemblies -contains $check_assembly_path)) {
        write-debug ('Already loaded: {0}' -f $assembly_path)
      } else {
        write-debug ('Not loaded: {0}' -f $assembly_path)
      }
    }
    return ($loaded_project_specific_assemblies -contains $assembly_path)
  }
}
