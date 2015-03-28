#!/bin/bash 
CONFIG_FILE=${1:-jsTestDriver.conf}
Xvfb :1000 -ac >/dev/null 2>&1 &
SELENIUM_NODE_PID=$!
export DISPLAY=:1000
# export DISPLAY=:1
# VNC is a better option if one needs to see the display
# TODO - investigate
# http://theseekersquill.wordpress.com/2010/03/16/vnc-server-ubuntu-windows/
# http://stevenharman.net/blog/archive/2008/12/13/vnc-to-a-headless-ubuntu-box.aspx
RUNNING_PID=$(sudo netstat -npl | grep 4224 | awk '{print $7}'| grep '/java'|head -1 | sed 's/\/.*$//')
if [ "$RUNNING_PID" != "" ] ; then
echo killing java $RUNNING_PID
kill -1 $RUNNING_PID
sudo ps ax -opid,comm,args |  grep java |  grep 4224  2>/dev/null| tail -1 | awk  '{print $1}' | xargs echo kill -1 
sleep 1
echo killing firefoxes
ps ax -opid,comm | grep firef | tail -1 | awk '{print $1}' | xargs echo kill -1
sleep 1
fi

PROFILE=$(grep -Eio 'Path=(.*)' ~/.mozilla/firefox/profiles.ini)
echo "Clearing firefox history in default profile $PROFILE"

{
rm ~/.mozilla/firefox/$PROFILE/cookies.txt
rm ~/.mozilla/firefox/$PROFILE/Cache/*
rm ~/.mozilla/firefox/$PROFILE/downloads.rdf
rm ~/.mozilla/firefox/$PROFILE/history.dat
}  > /dev/null 2>&1
sleep 3
echo setting java environment
export JAVA_HOME=/opt/jre1.6.0_31/
export PATH=$PATH:$JAVA_HOME/bin
export PATH=$PATH:/opt/firefox
echo  starting browser
java -jar jsTestDriver.jar --port 4224 --browser `which firefox` --testOutput /home/sergueik/Test/Logs &
SELENIUM_NODE_PID=$!
sleep 20
#
#lsof -b -i 
#
lsof -b -i TCP
MY_RUNNERMODE=DEBUG
MY_RUNNERMODE=QUIET
sleep 10
echo running tests
# http://code.google.com/p/js-test-driver/wiki/ContinuousBuild
java -jar jsTestDriver.jar --config /home/sergueik/Test/$CONFIG_FILE  --tests all --server http://localhost:4224 --captureConsole --testOutput /home/sergueik/Test/Logs/ --raiseOnFailure 1 --runnerMode $MY_RUNNERMODE
# http://code.google.com/p/js-test-driver/wiki/ContinuousBuild
# need to pass profile
{
kill -QUIT $SELENIUM_NODE_PID
}  > /dev/null 2>&1
# ps -p $(cat $(uname -n):1.pid)
# kill -TERM $(cat $(uname -n):1.pid)
