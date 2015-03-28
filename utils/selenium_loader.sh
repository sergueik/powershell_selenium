#!/bin/bash

NODE_PORT_ARG=$1

# This is bare bones standalone script to launch one node 
# it will have a parameter to run two or more nodes on separate displays

export NODE_PORT=5555
export HUB_PORT=4444
export SELENIUM_JAR_VERSION=2.43.1
export DEFAULT_CONFIG_FILE='node.json'

# This allows setting alternative port on the commandline 
if [ "$NODE_PORT_ARG" != "" ]
then
echo "Starting node on port $NODE_PORT_ARG"
NODE_PORT=$NODE_PORT_ARG
export CONFIG_FILE="/tmp/node.$NODE_PORT.json"
echo "Copying $DEFAULT_CONFIG_FILE to $CONFIG_FILE"
cp --force $DEFAULT_CONFIG_FILE $CONFIG_FILE
sed -i 's/"port":5555/"port":$NODE_PORT/' $CONFIG_FILE
export LOG_FILE=/var/log/node-${NODE_PORT}.log
else
export CONFIG_FILE=$DEFAULT_CONFIG_FILE
export LOG_FILE=/var/log/node.log
fi

/bin/readlink selenium-server-standalone.jar | grep -in $SELENIUM_JAR_VERSION >/dev/null
if [ $? != 0 ]
then 
echo "The Selenium version is incorrect: need version '$SELENIUM_JAR_VERSION'"
ls -l selenium*jar
exit 0
fi

# Detect the already running instances. Only one selenium node can run listening to a given port
echo "Checking if there is already process listening to ${NODE_PORT}"
RUNNING_PID=$(netstat -npl | grep $NODE_PORT | awk '{print $7}'| grep '/java'|head -1 | sed 's/\/.*$//')
if [ "$RUNNING_PID" != "" ] ; then
echo killing java $RUNNING_PID
ps -ocomm -oargs -p $RUNNING_PID
kill -HUP $RUNNING_PID
fi

if [ $TERM_FIREFOX_INSTANCES ] 
then
echo Killing firefoxes
# Terminate Firefox instances 
ps ax -opid,comm | grep [f]irefox | tail -1 | awk '{print $1}' | xargs echo kill -1
sleep 1

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

# TODO: introduce switch to run Xvfb or vncclient
if [ `/bin/false` ] 
then
export DISPLAY=:1000
# TODO : specify geometry of the display
Xvfb $DISPLAY -ac >/dev/null 2>&1 &
else
SERVICE_INFO=$(/sbin/service --status-all | egrep -i 'vncserver|xvnc')
echo $SERVICE_INFO
STATUS=$(expr "$SERVICE_INFO" : '.* is \(.*\)')
echo $STATUS | grep -ivn 'runnng'  > /dev/null
if [ $? != 0 ]
then
echo Starting service
/sbin/service vncserver start
fi
export DISPLAY=:1.0

fi
SELENIUM_NODE_PID=$!
export HUB_IP_ADDRESS=127.0.0.1
# This is options for java runtime.
export LAUNCHER_OPTS='-XX:MaxPermSize=256M -Xmn128M -Xms256M -Xmx256M'

# This runs the node jar in the background
java $LAUNCHER_OPTS -jar selenium-server-standalone.jar -role node -hub http://${HUB_IP_ADDRESS}:${HUB_PORT}/hub/register -nodeConfig $CONFIG_FILE -port $NODE_PORT -log ${LOG_FILE} &

SELENIUM_NODE_PID=$!
#
# lsof -b -i TCP
sleep 10
echo Press Enter to terminate
read stop
{
kill -HUP $SELENIUM_NODE_PID
sleep 120
kill -QUIT $SELENIUM_NODE_PID
}  > /dev/null 2>&1
# ps -p $(cat $(uname -n):1.pid)
# kill -TERM $(cat $(uname -n):1.pid)
