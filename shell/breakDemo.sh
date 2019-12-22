#!/bin/bash
#date:20190717
#author:meiguiwei
#description:breakDemo
if [ $# -ne 1 ]
	then
	echo $"usage:$0 {break|continue|exit|return}"
	exit 1
fi
test(){
	for (( i = 0; i < 10; i++ ))
	do
		if [ $i -eq 3 ]
			then
			$*;
		fi
		echo $i
	done
	echo "I anm in func"
}
test $*
func_ret=$?
if [ `echo $*|grep return|wc -l` -eq 1 ]
	then
	echo "return's exit status:$func_ret"
fi
echo "ok"
----------------------------------------------------------------
#demo1 冗余代码
#!/bin/bash
#description:continiueDemo
[ -f /etc/init.d/functions ] && . /etc/init.d/functions
RETAVL=0
add(){
	for ip in {1..16}
	do
		if [ $ip -eq 10 ]
			then
			continue
		fi
		ip addr add 10.0.2.$ip/24 dev eth0 label1 eth0:$ip & >/dev/null
		RETAVL=$?
		if [ $RETAVL -eq 0 ]
			then
			action "add $ip" /bin/true
		else
			action "add $ip" /bin/false
		fi
	done
}

del(){
	for ip in {1..16}
	do
		if [ $ip -eq 10 ]
			then
			continue 
		fi
		ifconfig eth0:$ip down &>/dev/null
		RETAVL=$?
		if [ $? -eq 0 ]
			then
			action "del $ip" /bin/true
		else
			action "del $ip" /bin/false
		fi
	done
}

case "$1" in
	start)
		add
		;;
	stop)
		del
		;;
	restart)
		del
		sleep 2
		add
		;;
	*)
	printf $"USAGE:$0 {start|stop|restart}"
esac
exit $RETAVL
------------------------------------------------------------------------
#demo1 减少冗余代码
#!/bin/bash
#description:continiueDemo
[ -d /etc/init.d/functions ] && . /etc/init.d/functions
RETVAL=0

op(){
	if [ $1 == "start" ]
		then
		list=`echo {1..16}`
		for ip in $list
		do
			if [ ip -eq 10 ]
				continue
			fi
			ip addr add 10.0.2.$ip/24 dev eth0 label1 eth0:$ip & >/dev/null
			RETVAL=$?
			if [ $RETVAL -eq 0 ]
				then
				action "add $ip" /bin/true
			else
				action "add $ip" /bin/false
			fi
		done
	elif [ $1 == "stop" ]
		then
		list=`echo {1..16}`
		for ip in $list
		do
			if [ $ip -eq 10 ]	
				then
				continue
			fi
			ifconfig eth0:$ip down &>/dev/null
			RETVAL=$?
			if [ $? -eq 0 ]
				then
				action "stop $ip" /bin/true
			else
				action "stop $ip" /bin/false
			fi
		done
	else
		echo $"usage: {start|stop}"
	fi
}

case "$1" in
	start)
		op start
		RETVAL=$?
		;;
	stop)
		op stop
		RETVAL=$?
		;;
	*)
		echo $"usage: {start|stop}"
esac
exit $RETVAL
---------------------------------



