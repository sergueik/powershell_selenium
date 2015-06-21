@echo OFF
REM works

set JAVA_VERSION=1.7.0_65
set GROOVY_VERSION=2.3.8
set MAVEN_VERSION=3.2.1

set JAVA_HOME=c:\java\jdk%JAVA_VERSION%
set GROOVY_HOME=c:\java\groovy-%GROOVY_VERSION%

set M2_HOME=c:\java\apache-maven-%MAVEN_VERSION%
set M2=%M2_HOME%\bin
set MAVEN_OPTS=-Xms256m -Xmx512m

PATH=%JAVA_HOME%\bin;%PATH%;%GROOVY_HOME%\bin;%M2%
call mvn.bat -Dmaven.test.skip=true -DskipTests=true clean package install

set TARGET=%CD%\target

java -cp target\app-1.1-SNAPSHOT.jar;c:\java\selenium\selenium-server-standalone-2.44.0.jar;target\lib\*  com.mycompany.app.App

goto :EOF


REM https://groups.google.com/forum/#!topic/selenium-users/i_xKZpLfuTk
