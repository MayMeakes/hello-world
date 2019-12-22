#!/bin/bash
#date:20190628
#description:MonitorMemoryUsage
#define variables
FreeMem=`free -m |awk 'NR==3 {print $NF}'`
CHARS="Current memory is $FreeMem."

if [ $FreeMem -lt 100 ]
then
	echo $CHARS |tee /tmp/mesages.txt
	mail -s "`date +%F-%T`$CHARS" test@oldboyedu.com </tmp/mesages.txt
fi


#!/bin/bash
#date:20190628
#description:MonitorMemoryUsage
#define variables
FreeMem=`free -m |awk 'NR==3 {print $NF}'`
CHARS="Current memory is $FreeMem."

if [ $FreeMem -lt 100 ]
then
	echo $CHARS |tee /tmp/mesages.txt
	mail -s "`date +%F-%T`$CHARS" test@oldboyedu.com </tmp/mesages.txt
fi
