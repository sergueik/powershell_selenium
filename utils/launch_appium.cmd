@echo OFF
set JAVA_VERSION=1.7.0_67
set JAVA_HOME=c:\progra~1\java\jdk%JAVA_VERSION%
set JAVA_HOME=c:\java\jdk%JAVA_VERSION%
set ANDROID_HOME=C:\java\adt-bundle-windows-x86-20130219\sdk
set APPIUM_H0ME=c:\tools\appium
REM for convenience only 
set MAX_MEMORY=-Xmx256m
set STACK_SIZE=-Xss8m
set LOGFILE=node.log4j.log

rem Need to keep 1.7 and 1.6 both installed
set GROOVY_HOME=c:\java\groovy-2.3.2
REM cannot use paths
PATH=%JAVA_HOME%\bin;%PATH%;%GROOVY_HOME%\bin
path=%path%;%ANDROID_HOME%;%ANDROID_HOME%\platform-tools
where.exe "AVD Manager.exe"
call "AVD Manager.exe"
CHOICE /T 1 /C ync /CS /D y 
pushd %APPIUM_H0ME%
call Appium.exe
popd
