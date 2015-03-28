#!/bin/bash

NODE_PORT_ARG=$1

# This is bare bones standalone script to launch one node 
# it will have a parameter to run two or more nodes on separate displays

# configuration -can? be shared
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

# This code detects the already running instances. Only one selenium node can run listening to a given port
#
echo "Checking if there is already process listening to ${NODE_PORT}"
RUNNING_PID=$(sudo netstat -npl | grep $NODE_PORT | awk '{print $7}'| grep '/java'|head -1 | sed 's/\/.*$//')
if [ "$RUNNING_PID" != "" ] ; then
echo killing java $RUNNING_PID
ps -ocomm -oargs -p $RUNNING_PID
# sending HUP
kill -HUP $RUNNING_PID
# echo
fi

if [ $TERM_FIREFOX_INSTANCES ] 
then
echo Killing firefoxes
# This code terminates Firefox instances 
# (unfinished)
# WARNING - all running will be stopped
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

export DISPLAY=:1000
# TODO : specify geometry of the display
Xvfb $DISPLAY -ac >/dev/null 2>&1 &
SELENIUM_NODE_PID=$!
export HUB_IP_ADDRESS=127.0.0.1
# This is options for java runtime.
export LAUNCHER_OPTS='-XX:MaxPermSize=256M -Xmn128M -Xms256M -Xmx256M'

# This runs the node jar in the background
java $LAUNCHER_OPTS -jar selenium-server-standalone.jar -role node -hub http://${HUB_IP_ADDRESS}:${HUB_PORT}/hub/register -nodeConfig $CONFIG_FILE -port $NODE_PORT -log ${LOG_FILE} &
