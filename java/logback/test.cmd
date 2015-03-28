@echo OFF
REM works
 call mvn clean package install
REM call mvn package install
set TARGET=%CD%\target

java -cp target\app-1.1-SNAPSHOT.jar;c:\java\selenium\selenium-server-standalone-2.44.0.jar;target\lib\*  com.mycompany.app.App

goto :EOF


REM https://groups.google.com/forum/#!topic/selenium-users/i_xKZpLfuTk
REM http://www.srccodes.com/p/article/5/Hello-World-Example-of-Simple-Logging-Facade-for-Java-or-SLF4J
REM http://www.srccodes.com/p/article/5/Hello-World-Example-of-Simple-Logging-Facade-for-Java-or-SLF4J
REM  The configuration seems to be ignored 
REM log4j.properties
REM log4j.xml
REM http://stackoverflow.com/questions/17548997/maven-include-resources-into-jar
REM http://stackoverflow.com/questions/4311026/how-to-get-slf4j-hello-world-working-with-log4j
REM When a console warning gives you a URL to look at, and the URL says Knowing the appropriate location to place log4j.properties or log4j.xml requires understanding the search strategy of the class loader in use.