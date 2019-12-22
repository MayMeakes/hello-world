#!/bin/bash
#description:Chapter9caseDemo
#date:20190713
#author:DanielMey
case "theConditionOfFindBoyfriend" in
	having houses)
		marry you
		;;
	having goodfamily)
		marry you
		;;
	tryallbest)
		marry you
		;;
	*)
		good bye!
esac

---------------------------------
#!/bin/bash
#this script is created by daniel
#numberDemo
read -p "Please input a number:" ans
case "$ans" in
	1)
		echo "the num you input is 1"
		;;
	2)
		echo "the num you input is 2"
		;;
	3)
		echo "the num you input is 3"
		;;
	[4-9])
		echo "the num you input is $ans"
		;;
	*)
	echo "Please input [1-9] int"
	exit;
esac

----------------------------------
#!/bin/bash
#this script is created by daniel
#numberDemobyIf
read -p "Please input a number:" ans
if [ $ans -eq 1 ]
	then
	echo "the number you input is 1"
elif [ $ans -eq 2 ]
	then
	echo "the number you input is 2"
elif [ $ans -ge 3 -a $ $ans -le 9 ]
	then
	echo "the number you input is $ans"
else
	echo "the num you input must be [1-9]"
	exit
fi


----------------------------------------
#给字体加颜色
echo -e "\E[1;31m红色字Daniel\E[0m"
echo -e 可以识别转义字符，这里将识别特殊字符的含义，并输出。
□ \E 可以使用\033 替代。
□ " [ 1" 数字1 表示加粗显示（可以加不同的数字，以代表不同的意思，详细信息
可用man console_ codes 获得）。
□ 31m 表示为红色字体，可以换成不同的数字，以代表不同的意思。
□ "红色字oldboy" 表示待设置的内容。
□ "[Om" 表示关闭所有属性，可以换成不同的数字，以代表不同的意思。
有关ANSI 控制码的说明如下。
□ \33[0m 表示关闭所有属性。
□ \33[1m 表示设置高亮度。
□ \33[4m 表示下划线。
□ \33[5m 表示闪烁。
□ \33[7m 表示反显。
□ \33[8m 表示消隐。
□ \33[30m -- \33[37m 表示设置前景色。
□ \33[40m -- \33[4 7m 表示设置背景色。
console codes 的更多知识可以参考man console_ codes, 普通读者了解即可。


-----------------------------------------
#!/bin/bash
#this script is created by daniel
#printFruitMenu
RED_COLOR='\E[1;31m'
GREEN_COLOR='\E[1;32m'
YELLOW_COLOR='\E[1;33m'
BLUE_COLOR='\E[1;34m'
RES='\E[0m['

echo ' #<=使用echo打印菜单，不过还是使用cat命令比较好
  =====================================
  1.apple
  2.pear
  3.banana
  4.cherry
  =====================================
  '
 read -p "please select a num:" num

 case "$num" in
 	1)
			echo -e "${RED_COLOR}${RES}"
 		;;
 	2)
			echo -e "${GREEN_COLOR}${RES}"
 		;;
 	3)
			echo -e "${YELLOW_COLOR}${RES}"
 		;;
 	4)
			echo -e "${BLUE_COLOR}${RES}"
 		;;
 	*)
		echo 'must be {1|2|3|4}'
 esac

----------------------------------------------
#!/bin/bash
#standardCaseMenu
#date:2010713
#author:Daniel
RED_COLOR='\E[1;31m'
GREEN_COLOR='\E[1;32m'
YELLOW_COLOR='\E[1;33m'
BLUE_COLOR='\E[1;34m'
RES='\E[0m['
function menu(){
	cat<<END
	1.apple
	2.pear
	3.banana
END
}
menu

read -p "pls input your choice:" ans
case "$ans" in
	1)
		echo -e "${RED_COLOR}${RES}"
		;;
	2)
		echo -e "${GREEN_COLOR}${RES}"
		;;
	3)
		echo -e "${GREEN_COLOR}${RES}"
		;;
	*)
		echo -e "no fruit you choose"
esac

---------------------------------------------------------------------------------------
#!/bin/bash
#date:20190713
#author:Daniel
#modUserList
. /etc/init.d/functions
#config file path
FILE_PATH=/etc/openvpn_authfile.conf
[ ! -f $FILE_PATH ] && touch $FILE_PATH
function usage(){
	cat <<EOF
	USAGE:`basename $0`{-add|-del|-search} username
EOF
}

#judge run user
if [ $# -ne 2 ]
	then
	usage
	exit 2
fi

#nextJudge
case "$1" in
	-a|add)
		shift
		if grep "^$1" ${FILE_PATH} >/dev/null 2>&1
			then
			action $"vpnuser,$1 is exit" /bin/fasle
			exit
		else
			chattr -i ${FILE_PATH}
			/bin/cp ${FILE_PATH} ${FILE_PATH}.$(date +%F%T)
			echo "$1" >>${FILE_PATH}
			[ $? -eq 0 ] && action $"Add $1" /bin/true

			chattr +i ${FILE_PATH}
		fi
		;;
	-d|-del)
		shift
		if [ `grep "\b$1|b" ${FILE_PATH}|wc -l` -lt 1 ]
			then
			action $"vpnuser,$1 is not exist." /bin/false
			exit
		else
			chattr -i ${FILE_PATH}
			/bin/cp ${FILE_PATH} ${FILE_PATH}.$(date +%F%T)	
			sed -i "/^${1}$/d" ${FILE_PATH}	
			[ $? -eq 0 ] && action $"Del $1" /bin/true
			chattr +i ${FILE_PATH}
			exit
		fi
		;;
	-s|search)
		shift
		if [ `grep -w "$1" ${FILE_PATH} |wc -l` -lt 1 ]
			then
			echo $"vpnuser,$1 is not exist."
			exit
		else
			echo $"vpnuser,$1 is exist."
			exit
		fi
	*)
		usage
		exit
		;;
esac
-----------------------------------------------------------
#!/bin/bash
#date:20190716
#author:Daniel
#description:start/stop NginxServer
path=/application/nginx/sbin
pid=/application/nginx/logs/nginx.pid
RETVAL=0
. /etc/init.d/functions

function start(){
	if [ ! -f $pid ]
		then
		$path/nginx
		RETVAL=$?
		if [ $RETVAL -eq 0 ]
			then
			action "niginx is started" /bin/true
			return $RETVAL
		else
			action "niginx is failed" /bin/false
			return $RETVAL
		fi
	else
		echo "niginx is running"
		return 0
	fi
}

function stop(){
	if [ -f $pid ]
		then
		$path/niginx -s stop
		RETVAL=$?
		if [ $? -eq 0 ]
			then
			echo "the niginx is stoppped" /bin/true
		else
			echo "then niginx is stopped" /bin/false
			return $RETVAL
		fi
	else
		echo "niginx is not running"
		return $RETVAL
	fi
}

case "$1" in
	start)
		start
		RETVAL=$?
		;;
	stop)
		stop
		RETVAL=$?
		;;
	restart)
		stop
		sleep 1
		start
		RETVAL=$?
		;;
	*)
		echo $"usage: $0{start|stop|restart}"
		exit 1
esac

exit $RETVAL

--------------------------------------------------------------















































































