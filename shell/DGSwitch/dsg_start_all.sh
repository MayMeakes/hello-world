#!/bin/bash

if [ `cat /dsg/dsg_num.txt` -ne "0" ];then

##启DSG
echo "Start DSG..."
bash /dsg/start_dsg_all.sh

##启动进程后进程检查命令
echo "Check DSG status..."
bash /dsg/checkstat.sh

else 
exit 1
fi