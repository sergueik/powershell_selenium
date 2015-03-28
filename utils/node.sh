#!/bin/bash

# This is bare bones standalone script to launch one node 
# it has  option parameter to specify port
# This allows run two or more nodes on separate displays

export NODE_PORT=5555
export HUB_IP_ADDRESS=127.0.0.1
export HUB_PORT=4444
export SELENIUM_JAR_VERSION=2.43.1
export DISPLAY_PORT=1000
export ROLE=node

usage() { cat<<END_OF_USAGE;exit 1; 

Usage: $0 [-s <NODE_PORT_ARG>] [-d [vnc|xvfb]] [-l <LOGFILE>]
Options specify

-s NODE_PORT_ARG Selenium node will be using (specific TCP port per node). Default is 5555
        Whe running on xvfb, a separate instance of Xvfb will run on DISPLAY_PORT_ARG where DISPLAY_PORT_ARG=NODE_PORT-4555
-d DRIVER driver - xvfb or vnv (experimental)

END_OF_USAGE

}

terminate(){
echo "Terminating the running instance(s):"
# TODO
ps ax | grep [j]ava | grep '\-role' | grep $ROLE
echo "This is currently a no-op"

exit 0
}

NODE_PORT_ARG=$NODE_PORT
DISPLAY_PORT_ARG=$DISPLAY_PORT
# use getopt 'short' here to get the input arguments
while getopts "hts:l:d:" arg; do
  case $arg in
    h)
      usage
      ;;

    t)
      terminate
      ;;
    s)
      NODE_PORT_ARG=$OPTARG
      echo NODE_PORT_ARG=$NODE_PORT_ARG
      ;;
    d)
      DRIVER_ARG=$OPTARG
      echo $DRIVER_ARG | egrep -in '^(vnc|xvfb)$' > /dev/null
      if [ $? != 0 ] 
      then
        echo "Unknown driver: ${DRIVER_ARG}"
        exit 1 
      fi 
      echo DRIVER_ARG=$DRIVER_ARG
      ;;
  esac
done
if [ "$DRIVER_ARG" == "xvfb" ]
then
   DISPLAY_PORT_ARG=$(expr $NODE_PORT_ARG - 4555)
   echo "No visible browser. Display will be set to: ${DISPLAY_PORT_ARG}" 
else
   echo "Visible browser window."
fi    
export DISPLAY_PORT=$DISPLAY_PORT_ARG

# configuration -can? be shared
export DEFAULT_CONFIG_FILE='node.json'

# This allows setting alternative port on the commandline 
if [ "$NODE_PORT_ARG" != "" ]
then
echo "Starting node on port $NODE_PORT_ARG"
NODE_PORT=$NODE_PORT_ARG

# use unique name for CONFIG_FILE
export CONFIG_FILE="/tmp/node.$NODE_PORT.json"
echo "Copying $DEFAULT_CONFIG_FILE to $CONFIG_FILE"
cp --force $DEFAULT_CONFIG_FILE $CONFIG_FILE

# default node.json file has port set to 5555
# the next command replaces the port with specified through NODE_PORT_ARG
sed -i 's/"port":5555/"port":$NODE_PORT/' $CONFIG_FILE
export LOG_FILE=/var/log/node-${NODE_PORT}.log
else
export CONFIG_FILE=$DEFAULT_CONFIG_FILE
export LOG_FILE=/var/log/node.log
fi



# This code verifies that correct version of selenium jar is linked to 
# simply selenium-sever-standalone.jar. 
# The hub and node use similar code to cleanup 

/bin/readlink selenium-server-standalone.jar | grep -in $SELENIUM_JAR_VERSION >/dev/null
if [ $? != 0 ]
then 
echo "The Selenium version is incorrect: need version '$SELENIUM_JAR_VERSION'"
ls -l selenium*jar
exit 0
fi
# This code detects if hub is already running. This is required, otherwise 
# the port listener based instance cleanup logic will not work.

netstat -npl | grep $HUB_PORT | awk '{print $7}'| grep -in '/java' >/dev/null
if [ $? == 0 ] 

then
echo "Confirmed hub is running. Continue with laucnhing the node"
else
echo "Please launch the Selenium hub on ${HUB_PORT} first." 
exit 1
fi
if [ `/bin/false` ] 
then
SERVICE_INFO=$(/sbin/service --status-all | egrep -i 'vncserver|xvnc')
echo '1'
echo $SERVICE_INFO
STATUS=$(expr "$SERVICE_INFO" : '.* is \(.*\)')
echo $STATUS | grep -ivn 'runnng'  > /dev/null
if [ $? != 0 ]
then
echo Starting service
/sbin/service vncserver start
fi
fi
# This code detects the already running instances. Only one selenium node can run listening to a given port
#
echo "Checking if there is already Selenium process listening to ${NODE_PORT} and terminating"
netstat -npl | grep $NODE_PORT | awk '{print $7}'| grep '/java'
RUNNING_PID=$(netstat -npl | grep $NODE_PORT | awk '{print $7}'| grep '/java'|head -1 | sed 's/\/.*$//')
if [ "$RUNNING_PID" != "" ] ; then
echo killing java $RUNNING_PID
ps -ocomm -oargs -opid -p $RUNNING_PID
# sending HUP
kill -HUP $RUNNING_PID
sleep 10
kill $RUNNING_PID

echo "Done."
fi

if [ $TERM_FIREFOX_INSTANCES ] 
then
echo Killing firefoxes
# This code terminates Firefox instances 
# (unfinished)
# WARNING - all running will be stopped
ps ax -opid,comm | grep [f]irefox | tail -1 | awk '{print $1}' | xargs kill -HUP 
sleep 10

PROFILE=$(grep -Eio 'Path=(.*)' ~/.mozilla/firefox/profiles.ini)
echo "Clearing firefox history in default profile $PROFILE"

{
rm ~/.mozilla/firefox/$PROFILE/cookies.txt
rm ~/.mozilla/firefox/$PROFILE/Cache/*
rm ~/.mozilla/firefox/$PROFILE/downloads.rdf
rm ~/.mozilla/firefox/$PROFILE/history.dat
}  > /dev/null 2>&1
sleep 3

fi
# Detect already running Xvfb. It is harmless to
# let run - the attempt to run second instance on the same
# port will fail

echo  "Detect already running Xvfb ${DISPLAY_PORT}"
RUNNING_PID2=$(netstat -npl | grep STREAM  |grep $DISPLAY_PORT| awk '{print $9}'|head -1 | sed 's/\/.*$//')
if [ "$RUNNING_PID2" != "" ] ; then
ps -ocomm -oargs -opid -p $RUNNING_PID2
echo killing Xvfb $RUNNING_PID2
# NOTE change of signal sent to Xvfb
kill $RUNNING_PID2
fi
export DISPLAY=:$DISPLAY_PORT
# TODO : specify geometry of the display
Xvfb $DISPLAY -ac >/dev/null 2>&1 &
SELENIUM_NODE_PID=$!
# This is options for java runtime.
export LAUNCHER_OPTS='-XX:MaxPermSize=256M -Xmn128M -Xms256M -Xmx256M'
echo "Starting Selenium in the background"
# This runs the node jar in the background

export SELENIUM_HOME=`pwd`

cat <<EEE
java $LAUNCHER_OPTS \
-classpath \
$SELENIUM_HOME/log4j-1.2.17.jar:$SELENIUM_HOME/selenium-server-standalone.jar: \
-Dlog4j.configuration=node.log4j.properties \
org.openqa.grid.selenium.GridLauncher \
-role node \
-host $NODE_HOST \
-port $NODE_PORT \
-hub http://${HUB_IP_ADDRESS}:${HUB_PORT}/hub/register \
-nodeConfig $NODE_CONFIG  \
-browserTimeout 12000 -timeout 12000 \
-ensureCleanSession true \
-trustAllSSLCertificates 

EEE

java $LAUNCHER_OPTS \
-classpath \
$SELENIUM_HOME/log4j-1.2.17.jar:$SELENIUM_HOME/selenium-server-standalone.jar: \
-Dlog4j.configuration=node.log4j.properties \
org.openqa.grid.selenium.GridLauncher \
-role node \
-host $NODE_HOST \
-port $NODE_PORT \
-hub http://${HUB_IP_ADDRESS}:${HUB_PORT}/hub/register \
-nodeConfig $NODE_CONFIG  \
-browserTimeout 12000 -timeout 12000 \
-ensureCleanSession true \
-trustAllSSLCertificates &

echo $NODE_PID
ps ax | grep [j]ava


# -browser "seleniumProtocol=WebDriver,browserName=firefox,maxInstances=5,platform=LINUX" \
# -browser "seleniumProtocol=Selenium,browserName=*firefox,maxInstances=5,platform=LINUX"  \
# -browser "seleniumProtocol=WebDriver,browserName=chrome,maxInstances=5,platform=LINUX" \
# -browser "seleniumProtocol=Selenium,browserName=*googlechrome,maxInstances=5,platform=LINUX" \
# -Dwebdriver.chrome.driver=/home/vncuser/selenium/seleniumchromedriver \
# -Dwebdriver.ie.driver.logfile=c:\selenium\logs\IEDriverServerWin64.log \
# -Dwebdriver.logging.Level=ALL \
