#!/bin/bash

dsg_num=` ps -ef|grep dsg|grep -v grep|wc -l ` 
echo "$dsg_num" > /dsg/dsg_num.txt

if [ "${dsg_num}" -ne "0" ];then
  echo "Have DSG processes,Please check..."
  ##停DSG进程
  echo "Start to stop DSG..."
  bash /dsg/stop_dsg_all.sh
  sleep 10
  bash /dsg/check.sh >/dsg/check.txt
      if [ ` cat /dsg/check.txt ` -eq "0" ];then
  	    echo "DSG has been stopped successfully"     
      else 
        echo "DSG has not been completely stopped,please confirm... "
  	    exit 1
      fi
else
  echo "There is not DSG,continue..."
  
fi
