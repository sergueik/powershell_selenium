@echo OFF
set IE=-Dwebdriver.ie.driver="%cd%\IEDriverServer.exe"
set CHROME=-Dwebdriver.chrome.driver="%cd%\chromedriver.exe"
set PHANTOM=-Dphantomjs.binary.path="%cd%\phantomjs.exe"
REM to set a custom location of Firefox driver, update and uncomment the next line:
REM set FIREFOX_LOCATION_ARGUMENT=-Dwebdriver.firefox.bin="C:\\Users\\vagrant\\Desktop\\Firefox\\firefox.exe"
REM Provide the pathname of Selenium jar
set SELENIUM_SERVER_EXE=selenium-server-standalone-2.45.0.jar
REM to prevent the argument list too long error, remove 'start "%SELENIUM_SERVER_EXE%"' from the command below
start "%SELENIUM_SERVER_EXE%" java %PHANTOM% %CHROME% %IE% %FIREFOX_LOCATION_ARGUMENT% -jar %SELENIUM_SERVER_EXE%
