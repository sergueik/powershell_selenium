About
=====
Collection of Powershell scripts and modules for work with Selenium C# Client 

![Developing Selenium Scripts in Powershell ISE](https://raw.githubusercontent.com/sergueik/powershell_selenium/master/screenshots/55a.png)

Prerequisites
------------- 
Common functionality is in the modules `page_navigation_common.psm1` and `selenium_common.psm1`
Powershell uses C# Selenium Client API library and a few of standard asemblies which are stored in the location:

   Directory: C:\developer\sergueik\csharp\sharedassemblies
    log4net.dll
    nunit.core.dll
    nunit.framework.dll
    nunit.mocks.dll
    pnunit.framework.dll
    WebDriver.dll
    WebDriver.Support.dll

The Selenium JARs are supposed to be installed under `c:\java\selenium`:
    chromedriver.exe
    hub.cmd
    hub.json
    hub.log4j.properties
    log4j-1.2.17.jar
    node.cmd
    node.json
    node.log4j.properties
    node.xml
    selenium-server-standalone-2.47.1.jar

The standard Java applications are all supposed to be installed under `c:\java`:
    c:\java\
    c:\java\apache-maven-3.3.3
    c:\java\groovy-2.4.4
    c:\java\jdk1.7.0_79
    c:\java\jre7
    c:\java\selenium

The Java applications  and framework versions  need to be updated in `hub.cmd`, `node.cmd` e.g.	

    set SELENIUM_VERSION=2.47.1
    set GROOVY_VERSION=2.4.4
    set JAVA_VERSION=1.7.0_79
    set MAVEN_VERSION=3.3.3
    set JAVA_HOME=c:\java\jdk%JAVA_VERSION%
    set GROOVY_HOME=c:\java\groovy-%GROOVY_VERSION%

Skeleton script
---------------
To run a Selenium test in Powershell, start with the following script:
		param(
		  [string]$browser = '',
		  [string]$base_url = 'https://www.indiegogo.com/explore#',
		  [switch]$grid,
		  [switch]$pause
		)

		$MODULE_NAME = 'selenium_utils.psd1'
		Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
		if ([bool]$PSBoundParameters['grid'].IsPresent) {
		  $selenium = launch_selenium -browser $browser -grid

		} else {
		  $selenium = launch_selenium -browser $browser

		}
		$selenium.Navigate().GoToUrl($base_url)


		# Cleanup
		cleanup ([ref]$selenium)


Run the script with the option:

     . ./test_script -browser chrome
Scripts
-------
There is over 50 Standalone scripts illustrating misc. typical Selenium-related tasks in a problem-solution fashion. 
Most of these scripts can be reused.

|script|description 
| -------|:-------------:|
| powershell/ajax.ps1||
| powershell/alert_send.ps1||
| powershell/async_script.ps1||
| powershell/basic_javascript.ps1||
| powershell/bn.ps1||
| powershell/bookingengine_new.ps1||
| powershell/calendar.ps1||
| powershell/canvas_actions.ps1||
| powershell/carnival_itinerary_maps.ps1||
| powershell/carnival_itinerary_maps_part1.ps1||
| powershell/carnival_itinerary_maps_part2.ps1||
| powershell/carnival_itinerary_maps_part3.ps1||
| powershell/carnival_octopus_logon.ps1||
| powershell/carnival_search.ps1||
| powershell/chromecustomizations.ps1||
| powershell/chrome_load_times.ps1||
| powershell/chrome_preferences.ps1||
| powershell/codeproject.ps1||
| powershell/context_click.ps1||
| powershell/context_menu.ps1||
| powershell/cookie_management.ps1||
| powershell/crop_2.ps1||
| powershell/crop_screen_element.ps1||
| powershell/debug_selenium.ps1||
| powershell/degrade21_ie.ps1||
| powershell/dimensions.ps1||
| powershell/display_profile.ps1||
| powershell/download_profile.ps1||
| powershell/dropdowns.ps1||
| powershell/error_capture_screenshot.ps1||
| powershell/event_firing.ps1||
| powershell/event_firing_all.ps1||
| powershell/excel_data_source.ps1||
| powershell/expedia.ps1||
| powershell/extract_itinerary_map.ps1||
| powershell/fiddler-demo.ps1||
| powershell/firefox_download.ps1||
| powershell/flightaware.ps1||
| powershell/funville.ps1||
| powershell/get_cookie2.ps1||
| powershell/get_sessionid.ps1||
| powershell/hal.ps1||
| powershell/hal2.ps1||
| powershell/highlight.ps1||
| powershell/hover_example.ps1||
| powershell/hover_example2.ps1||
| powershell/html_parse.ps1||
| powershell/ie10_popup.ps1||
| powershell/ie_workarounds.ps1||
| powershell/iframes.ps1||
| powershell/kendo.ps1||
| powershell/keynote_s1.ps1||
| powershell/keynote_s2.ps1||
| powershell/keynote_s3.ps1||
| powershell/keynote_s4.ps1||
| powershell/keynote_s5.ps1||
| powershell/log_collector.ps1||
| powershell/manage_windows.ps1||
| powershell/mid_complex_xpath.ps1||
| powershell/mouse.ps1||
| powershell/node_logs.ps1||
| powershell/page_ready.ps1||
| powershell/parse_console.ps1||
| powershell/popups.ps1||
| powershell/priceline.ps1||
| powershell/pseudo_mobile.ps1||
| powershell/pseudo_mobile2.ps1||
| powershell/pseudo_mobile_template.ps1||
| powershell/razor_processor.ps1||
| powershell/refresh_windows_key.ps1||
| powershell/royalcaribbean.ps1||
| powershell/sample_framework.ps1||
| powershell/scroll_list.ps1||
| powershell/seabourn.ps1||
| powershell/selenium_actions.ps1||
| powershell/selenium_by_jquery.ps1||
| powershell/selenium_cloud.ps1||
| powershell/selenium_console_addon.ps1||
| powershell/selenium_dirty_version.ps1||
| powershell/selenium_dragdrop.ps1||
| powershell/selenium_dragdrop2.ps1||
| powershell/selenium_dsl.ps1||
| powershell/selenium_rc.ps1||
| powershell/selenium_run_testsuite.ps1||
| powershell/selenium_webdriver.ps1||
| powershell/selenium_webdriver_extensions.ps1||
| powershell/selenium_with_typeaccel.ps1||
| powershell/send_windows_keys.ps1||
| powershell/session_timeout_assert.ps1||
| powershell/shorex_browse_destination.ps1||
| powershell/shorex_browse_destination_old.ps1||
| powershell/shorex_carousel_box_image.ps1||
| powershell/shorex_destinations_paginator.ps1||
| powershell/shorex_hover_explore.ps1||
| powershell/sqlite3_location.ps1||
| powershell/swd_example_base.ps1||
| powershell/timeouts.ps1||
| powershell/timings.ps1||
| powershell/upload_file.ps1||
| powershell/urbandictionary.ps1||
| powershell/urbandictionary2.ps1||
| powershell/vendor_specific_capabilities.ps1||
| powershell/wait.ps1||
| powershell/webdriver_event_firing.ps1||
| powershell/with_profile.ps1||
| powershell/with_useragent.ps1||
| powershell/xpath_iterator.ps1||
| powershell/youtube.ps1||
| powershell/zoom.ps1||

Modules
-------

|Module|Description 
| -------|:-------------:|
| selenium_utils.psd1||
| page_navigation_common.psm1||
| selenium_common.psm1||

Usage:

  $browser_name = 'chrome'
  $MODULE_NAME = 'selenium_utils.psd1'
  Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
  $selenium = launch_selenium -browser $browser_name



Note: 

Older scripts contain the functionality inline. There are few scripts that still do, for some reason.

History
-------
Sat Mar 28 16:24:58 2015 extracted selenium scripts of [powershell_ui_samples](https://github.com/sergueik/powershell_ui_samples)  repository




Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)

