@echo OFF
REM works
call mvn.bat -Dmaven.test.skip=true -DskipTests=true clean package install
set TARGET=%CD%\target

java -cp target\app-1.1-SNAPSHOT.jar;c:\java\selenium\selenium-server-standalone-2.44.0.jar;target\lib\*  com.mycompany.app.App

goto :EOF


REM https://groups.google.com/forum/#!topic/selenium-users/i_xKZpLfuTk
