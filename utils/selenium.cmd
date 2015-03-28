@echo OFF
pushd %~dp0
set HTTP_PORT=4444
set HTTPS_PORT=-1
set SELENIUM_VERSION=2.44.0
set GROOVY_VERSION=2.3.8
set JAVA_VERSION=1.6.0_45
set MAVEN_VERSION=3.2.1
set JAVA_HOME=c:\java\jdk%JAVA_VERSION%
set GROOVY_HOME=c:\java\groovy-%GROOVY_VERSION%
set M2_HOME=c:\java\apache-maven-%MAVEN_VERSION%
set M2=%M2_HOME%\bin
set MAVEN_OPTS=-Xms256m -Xmx512m
PATH=%JAVA_HOME%\bin;%PATH%;%GROOVY_HOME%\bin;%M2%

PATH=%PATH%;c:\Program Files\Mozilla Firefox
WHERE firefox.exe
CHOICE /T 1 /C ync /CS /D y

REM This setting needs adjustment.
REM set LAUNCHER_OPTS=-XX:PermSize=512M -XX:MaxPermSize=1028M -Xmn128M -Xms512M -Xmx1024M


set LAUNCHER_OPTS=-XX:MaxPermSize=1028M -Xmn128M
java %LAUNCHER_OPTS% -jar selenium-server-standalone-%SELENIUM_VERSION%.jar -port %HTTP_PORT%
	
REM https://code.google.com/p/selenium/wiki/InternetExplorerDriver
rem http://seleniumonlinetrainingexpert.wordpress.com/2012/12/11/how-do-i-start-the-internet-explorer-webdriver-for-selenium/
goto :EOF 

REM Error occurred during initialization of VM
REMThe size of the object heap + VM data exceeds the maximum representable size
REM Error occurred during initialization of VM
REM Could not reserve enough space for object heap
REM Could not create the Java virtual machine.
REM 
REM pushd c:\Users\sergueik\AppData\Local\Mozilla Firefox
REM mklink /D c:\tools\firefox .
REM symbolic link created for c:\tools\firefox <<===>> .