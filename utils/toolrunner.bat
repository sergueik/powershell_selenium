@echo off

set SOAPUI_HOME=%~dp0


set JAVA_VERSION=1.7.0_65
set JAVA_HOME=c:\java\jdk%JAVA_VERSION%

set GROOVY_VERSION=2.3.8
set GROOVY_HOME=c:\java\groovy-%GROOVY_VERSION%

set MAVEN_VERSION=3.2.1

REM Do not use bundled java even if directory is present
set SKIP_BUNDLED_JAVA=1
if "%SKIP_BUNDLED_JAVA%" == "1" goto :SKIP_BUNDLED_JAVA_DETECTION

if exist "%SOAPUI_HOME%..\jre\bin" goto SET_BUNDLED_JAVA

:SKIP_BUNDLED_JAVA_DETECTION

if exist "%JAVA_HOME%" goto SET_SYSTEM_JAVA

echo JAVA_HOME is not set, unexpected results may occur.
echo Set JAVA_HOME to the directory of your local JDK to avoid this message.
goto SET_SYSTEM_JAVA

:SET_BUNDLED_JAVA
set JAVA=%SOAPUI_HOME%..\jre\bin\java
goto END_SETTING_JAVA

:SET_SYSTEM_JAVA
set JAVA=java

:END_SETTING_JAVA

rem init classpath

set CLASSPATH=%SOAPUI_HOME%soapui-pro-5.1.1.jar;%SOAPUI_HOME%..\lib\*
"%JAVA%" -cp "%CLASSPATH%" com.eviware.soapui.tools.JfxrtLocator > %TEMP%\jfxrtpath
set /P JFXRTPATH= < %TEMP%\jfxrtpath
del %TEMP%\jfxrtpath
set CLASSPATH=%CLASSPATH%;%JFXRTPATH%

rem JVM parameters, modify as appropriate
set JAVA_OPTS=-Xms128m -Xmx1024m -Dsoapui.properties=soapui.properties -Dgroovy.source.encoding=iso-8859-1 "-Dsoapui.home=%SOAPUI_HOME%\"

if "%SOAPUI_HOME%\" == "" goto START
    set JAVA_OPTS=%JAVA_OPTS% -Dsoapui.ext.libraries="%SOAPUI_HOME%ext"
    set JAVA_OPTS=%JAVA_OPTS% -Dsoapui.ext.listeners="%SOAPUI_HOME%listeners"
    set JAVA_OPTS=%JAVA_OPTS% -Dsoapui.ext.actions="%SOAPUI_HOME%actions"

:START

rem ********* run soapui toolrunner ***********

"%JAVA%" %JAVA_OPTS% -cp "%CLASSPATH%" com.eviware.soapui.SoapUIProToolRunner %*