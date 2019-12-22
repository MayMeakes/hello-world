#!/bin/bash
#date:20190628
#author:Meiguiwei
#description:MonitorDifferentService

#mysqld
echo method1-----------------------------
if [ `netstat -lnt |grep 3306|awk -F "[ :]" '{print $5}'` -eq 3306 ]
then
	echo "Mysql is running"
else
	echo "Mysql is Stopped"
	/etc/init.d/mysqld start
fi

echo method2----------------------------
if [ "`netstat -lnt|grep 3306|awk -F "[ :]" '{print $5}'`" -eq "3306" ]
then
	echo "mysql is running"
else
	echo "mysql is stopped"
	/etc/init.d/mysql
fi

echo method3---------------------------
if [ `netstat -lntup|grep mysqld |wc  -l ` -gt 0 ]
then
	echo "mysql is running"
else
	echo "mysql is stopped"
	/etc/init.d/mysql
fi

echo method4---------------------------
if [ `lsof -i tcp:3306|wc -l` -gt 0 ]
then
	echo "Mysql is running"
else
	echo "Mysql is Stopped"
	/etc/init.d/mysql
fi

echo method5---------------------------------
[ `rpm -qa nmap|wc -l` -lt 1 ] && yum install nmap -y &>/dev/null
if [ `nmap 127.0.0.1 -p 3306 2`>/dev/null |grep open|wc -l` -gt 0 ]
then
	echo "Mysql is running"
else
	echo "Mysql is Stopped"
	/etc/init.d/mysql
fi


echo method6------------------------
[ `rpm -qa nc|wcl -l` -lt 1 ] && yum install nc -y &>/dev/null
if [ `nc -w 2 127.0.0.1 3306 &>/dev/null&&echo ok|grep ok |wc -l` -gt 0 ]
then
	echo "Mysql is running"
else
	echo "Mysql is Stopped"
	/etc/init.d/mysqld start
fi

echo method7--------------------------------------
if [ `ps -ef |grep -v grep|grep msyql|wc -l ` -gt 0 ]
then
	echo "Mysql is running"
else
	echo "Mysql is stopped"
	/etc/init.d/mysqld	start
fi



#ClassicDemo

#!/bin/bash
#date:20190702
#author:Meiguiwei
#description：IfDemo
a=$1
b=$2
#no.1 judge arg nums
if [ $# -ne 2 ];then
	echo "USGAGE:$0 arg1 arg2"
	exit 2
fi

#no.2judge if init
expr $a + 2 &>/dev/null
RETVAL1=$?
expr $b + 2 &>/dev/null
RETVAL2=$?

if [ $RETVAL1 -ne 0 -a $RETVAL2 -ne 0 ];then
	echo "Pls input two int again"
	exit 3
fi

#no.3 compart two num
if [ $a -lt $b ];then
	echo "$a < $b"
elif [ $a -eq $b ]; then
	echo "$a = $b"
else
	echo "$a > $b"
fi

#!/bin/bash
#date:20190702
#author:Meiguiwei
#description：IfDemo
read -p "pls input two num:" a b
#no2 judge a and b if is int
expr $a + 0 &>/dev/null
RETVAL1=$?
expr $b + 0 &>/dev/null
RETVAL2=$?
if [ -z "$a" ] || [ -z "$b" ]
then
	echo "pls input two int again"
	exit 1
elif test $RETVAL1 -ne 0 -o $RETVAL2 -ne 0
	then
		echo "pls input two num again"
		exit 2
elif [ $a -lt $b ]
	then
		echo "$a < $b"
elif [ $a -eq $b ]
	then
		echo "$a = $b"
else
	echo "$a > $b"
fi
exit 0


#!/bin/bash
#date:20190702
#author:Meiguiwei
#description：IfDemo
[  -n "`echo oldboy123|sed 's/[0-9]//g'`" ] &&echo char || echo int

[  -z "`echo oldboy123|sed 's/[0-9]//g'`" ] &&echo char || echo int

#!/bin/bash
#date:20190702
#author:Meiguiwei
#description：IfDemo
if [ $# -ne 1 ]
	then
	echo $"usage:$0 { start|stop|restart }"
	exit 1
fi

if [ "$1" = ["start" ]
	then
	rsync --daemon
	sleep 2
	if [ `netstat -lntup|grep rsync|wc -l` -ge 1 ]
		then
		echo "rsync is started"
		exit 0
	fi
elif [ "$1" = "stop" ]
	then
	killall rsync &>/dev/null
	exit 0 
fi
elif [ $1 = "restart" ]
	then
	killall rsync
	sleep 1
	killpro=`netstat -lntup|grep rsync|wc -l`
	rsync --daemon
	sleep 1
	startpro=`netstat -lntup |grep rsync|wc -l`
	if [ $killpro -eq 0 -a $startpro -ge 1 ]
		then
		echo "rsync is restarted"
		exit 0
	fi
else
	echo $"usage:$0 {start|stop|restart}"
	exit 1
fi
#!/bin/bash
#date:20190702
#author:Meiguiwei
#description：professionRsyncScripts
if [ $# -ne 1 ]
	then
	echo $"usage:$0 {start|stop|restart}"
	exit 1
fi
if [ "$1" = "start" ]
	then
	rysnc --daemon
	sleep 2
	if [ `netstat -lntup|grep rsync |wc -l` -ge 1 ]
		then
		echo "rsync is started"
		exit 0
	fi
elif [ "$1" = "stop" ]
	then
	killall rsync &>/dev/null
	sleep 2
	if [ `netstat -lntup|grep rsync |wc -l` -eq 0 ]
		then
		echo "rsync is stoped"
		exit 0
	fi
elif [ "$1" = "restart" ]
	then
	kilall rsync
	sleep 1
	killpro=`netstat -lntup|grep rsync|wc -l`
	rsync -daemon
	sleep 1
	startpro=`netstat -lntup|grep rsync|wc -l`
	if [ $killpro -eq 0 -a $startpro -ge 1 ]
		then
		echo "rsync is restarted"
		exit 0
	fi
else
	echo $"usage:$0 {start|stop|restart}"
	exit 1
fi


