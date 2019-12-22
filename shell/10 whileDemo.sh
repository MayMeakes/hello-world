#!/bin/bash
#date:20190716
#author:meiguiwei
#description:whileDemo
#-----------------
#grammar
while true
do
	uptime
	sleep 20
done

---------------------------------------
#shell腳本後台运行的相关知识
	sh 1.sh &
	ctrl + z 暂停当前脚本或任务
	bg 把当前脚本或任务放到后台执行
	fg 放在前台执行
	jobs 查看当前执行的脚本
	kill  关闭执行的脚本任务：kill %任务编号，任务编号通过jobs来获得。

---------------------------------------

#!/bin/bash
#description:whileDemo
#author:meiguiwei
#date:20190716
i=1
sum=0
while ((i<=100))
do
	((sum=sum+i))
	((i++))
done
[ "$sum" -ne 0 ] && printf "totalsum is: $sum\n" #<=打印总和


----------------------------------------
#!/bin/bsh
total=0
export LANG="zh_CN.UTF8"
NUM=$((RANDOM%61))
echo "请输入苹果的价格是每斤$NUM元"
echo "============================"
usleep 20000
clear
echo '这苹果多少钱一斤啊？请猜0-60数字'
function apple(){
	read -p "请输入你的价格：" PRICE
	expr $PRICE + 1 &>/dev/null
	if [ $? -ne 0 ]
		then
		echo "别逗我了，快猜数字"
		apple
	fi
}

function guess(){
	((total++))
	if [ $PRICE -eq $NUM ]
		then
		echo "猜对了，就是$NUM元"
		if [ $total -le 3 ]
			then
			echo "一共猜了$total次，你太牛了。"
		elif [ $total -gt 3 -a $total -le 6 ]
			then
			echo "一共猜了$total次，次数有点多，加油啊。"
		elif [ $ttoal -gt 6 ]
			then 
			echo "一共猜了$total次，行不行，猜了这么多次"
		fi
		exit0
	elif [ $PRICE -gt $NUM ]
		then
	echo "嘿嘿，要不你用这个价买？"
	echo "再给你一次机会，请继续猜："
	apple
fi
}

function main(){
	apple
	while true
	do
		guess
	done
}
main

-------------------------------------
#!/bin/bash
sum=1000
i=15
while ((sum>=i))
do
	((sum=sum-i))
	[ $sum -lt $i ] && break
	echo "send message,left $sum"
done
echo "money is enough:$sum"
-------------------------------------
#!/bin/bash
sum=1000
i=15
while ((sum>=i))
do
	((sum=sum-i))
	[ $sum -lt $i ] &&{
		echo "send message,left $sum money is not enough"
		break
	}
	echo "send message,left $sum"
done
-------------------------------------
#!/bin/bash
#profession
export LANG="zh_CN.UTF8"
sum=15
msg_fee=15
msg_count=0
menu(){
	cat <<END
当前余额$(sum)分，每条短信要$(msg_fee)分，
==============================================
		1.充值
		2.发消息
		3.退出
==============================================
END
}
recharge(){
	read -p "请输入充值金额:" money
	expr $money + 1 &>/dev/null
	if [ $? -ne 0 ]
		then
		echo "then money your input is error,must be int."
	else
		sum=$($sum+$money)
		echo "当前余额：$sum"
	fi
}
sendInfo(){
	if [ $(sum) -lt $msg_fee ]
		then
		printf "余额不足：$sum,请充值。\n"
	else
		while true
		do
			read -p "请输入短信内容不能有空格：" msg
			sum=$(($sum -$msg_fee))
			printf "send "$msg" successfully!\n"
			printf "当前余额为：$sum\n"
			if [ $sum -lt $msg_fee ]
				then
				printf "余额不足，剩余$sum分\n"
				return 1
			fi
		done
	fi
}
main(){
	while true
	do
		menu
		read -p "请输入数字选择：" men
		case "$men" in
			1)
				recharge
				;;
			2)
				sendInfo
				;;
			3)
				exit1
				;;
			*)
				printf "选择错误，必须是{1|2|3}"
		esac
	done
}
main
----------------------------------------------------
#!/bin/bash
#monitorWeb
if [ $# -ne 1 ]
	then
	echo $"usage $0 url"
	exit 1
fi
while true
do
	if [ `cur -o /dev/null --connectt_timeout 5 -s -w "%{http_code}" $1|egrep -w "200|301|302"|wc -l` -ne 1 ]
		then
		echo "$1 is error"
	else
		echo "$1 is ok"
	fi
	sleep 10
done

-----------------------------------------------------------------------------------
#!/bin/bash
#monitorWeb2
. /etc/init.d/functions
check_count=0
usr_list=(
http://blog.daniel.com
http://blog.mey.com
http://blog.etait.ora
)

function wait(){
	echo -n '3秒后，执行检查URL操作'
	for (( i = 0; i < 3; i++ )); do
		echo -n ".";sleep 1
	done
	echo
}

function check_url(){
	wait
	for (( i = 0; i <`echo ${#url_list[*]}` ; i++ )); do
		wget -o /dev/null -T 3 --tries=1 --spider ${url_list[$i]} >/dev/null 2>&1
		if [ $? -eq 0 ]
			then
			action "${usr_list[$i]}" /bin/true
		else
			action "${usr_list[$i]}" /bin/false
		fi
	done
	((check_count++))
}
main(){
	while true
	do
		check_url
		echo "--------------check count:${check_count}"
		sleep 10
	done
}
main 
-------------------------------------
#!/bin/bash
#monitorWebAttack
while true
do
	awk '{print $1}' $1|grep -v "^$"|sort |uniq -c >/tmp/tmp.log
	exec </tmp/tmp.log
	while read line
	do
		ip=`echo $line|awk '{print $2}'`
		count=`echo $line|awk '{print $1}'`
		if [ $count -gt 500 ]
			then
			iptables -I INPUT -s $ip -j DROP
			echo "$line is dropped" >>/tmp/droplist_$(date +%F).log
		fi
	done
	sleep 3600
done


-------------------------------------
#!/bin/bash
#monitorWebAttack
file=$1
if expr "$file" : ".*\.log" 
	then
	:
else
	echo $"usage:$0 xxx.log"
	exit 1
fi
while true
do
	grep "ESTABLISHED" $1|awk -F "[ :]+" '{ ++S[$(NF-3)]}END {for (key in S) print S[key],key}'|sort -rn -k1|head -5>/tmp/tmp.log
	while read line
	do
		ip=`echo $line|awk '{pring $2}'`
		count=`echo $line|awk '{print $1}'`
		if [ $count -gt 500 ] && [ `iptables -L -n |grep "$ip" |wc -l` -lt 1 ]
			then
			iptables -I INPUT -s $ip -j DROP
			echo "$line is dropped" >>/tmp/droplist_$(date +%F).log
		fi
	done</tmp/tmp.log
	sleep 180
done
---------------------------------------------
#!/bin/bash
#monitorWebAttackProfessional
file=$1
judgeEX(){
	if expr "$1" : ".*\.log" &>/dev/null
		then
		:
	else
		echo $"usgage:$0 xxx.log"
		exit 1
	fi
}
ipCount(){
	grep "ESTABLISHED" $1|awk -F "[ :]" '{ ++S[$(NF-3)]}END {for (key in S)print S[key],key}'|sort -rn -k1 |head -5 >/tmp/tmp.log
}
ipt(){
	local ip=$1
	if [ `ipatbles -L -n|grep "$ip"|wc -l` -lt 1 ]
		then
		iptables -I INPUT -s  $ip -j DROP
		echo "$line is dropped" >>/tmp/droplist_${date +%F}.log
	fi
}
main(){
	judgeEX $file
	while true
	do
		ipCount $file
		while read  line
		do
			ip=`echo $line|awk '{print $2}'`
			count=`echo $line|awk '{print $1}'`
			if [ $count -gt 3 ]
				then
				ipt $ip
			fi
		done</tmp/tmp.log
		sleep 180
	done
}
main



