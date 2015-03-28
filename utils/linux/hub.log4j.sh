#!/bin/bash
# This is the standalone launcher script for hub it is listening to 4444
export HUB_PORT=4444
export SELENIUM_JAR_VERSION=2.43.1

# This code verifies that selenium jar of the correct version is linked to 
# simply selenium-sever-standalone.jar
/bin/readlink selenium-server-standalone.jar | grep -in $SELENIUM_JAR_VERSION
if [ $? != 0 ]
then 
echo "The Selenium version is incorrect: need version '$SELENIUM_JAR_VERSION'"
ls -l selenium*jar
exit 0
fi
# This code detects the already running instances. Only one selenium hub can run at a time
#
RUNNING_PID=$(sudo netstat -npl | grep $HUB_PORT | awk '{print $7}'| grep '/java'|head -1 | sed 's/\/.*$//')
if [ "$RUNNING_PID" != "" ] ; then
echo killing java $RUNNING_PID
ps -ocomm -oargs -p $RUNNING_PID
# sending HUP
kill -HUP $RUNNING_PID
# echo
fi

# This is options for java runtime.
export LAUNCHER_OPTS='-XX:MaxPermSize=256M -Xmn128M -Xms256M -Xmx256M'

java $LAUNCHER_OPTS -Dlog4j.configuration=log4j.properties -cp log4j-1.2.17.jar:selenium-server-standalone.jar:log4j.xml:log4j.properties org.openqa.grid.selenium.GridLauncher -role hub  -port $HUB_PORT &
