#!/bin/sh
export LOG=$HOME/log.txt
cat /dev/null>$LOG
for FILE in '/var/log/a.txt' '/etc/X11/a.txt' 
do
echo $FILE
echo "cat <<END>$FILE
This is a test
END
" | sudo -s 
ls -l $FILE | tee -a $LOG
sudo rm -f $FILE
done

