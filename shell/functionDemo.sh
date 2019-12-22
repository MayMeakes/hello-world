#!/bin/bash
#description:functionDemo
#author:Meiguiwei
#date:20190712
daniel(){
	echo "I am daniel"
}
function danielmey(){
	echo "I am danielmey"
}

#description:append function to fuctionfile of system
cat >>/tmp/disastermonitor/funcions<<- EOF
danielmey(){
	echo "I am danielmey"
}
EOF

#testfunction
[ -f /tmp/disastermonitor/funcions ] && ./tmp/disastermonitor/funcions||exit 1
danielmey xiaoming


#/bin/bash
cat >>/tmp/disastermonitor/funcions<<- EOF
danielmey(){
	echo "I am danielmey,you are $1"
}
EOF

--------------------------------------
#/bin/bash
#description:monitorWebURL
#author:meiguiwei
#date:20190713
if [ $# -ne 1 ]
	then
	echo $"usage:$0 url"
	exit 1
fi
#useWgetTestWehterLogin
wget --spider -q -o /dev/null --tries=1 -T 5 $1

if [ $? -eq 0 ]
	then 
	echo "$1 is yes."
else
	echo "$1 is no"
fi
--------------------------------------
#/bin/bash
#description:monitorWebURLuseFunction
#author:meiguiwei
#date:20190713
function usage(){
	echo $"usage:$0 url"
	exit 1
}

function check_url(){ #<==检测URL函数
	wget --spider -q -o /dev/null --tries=1 -T 5 $1
	if [ $? -eq 0 ]
		then
		echo "$1 is yes"
	else
		echo "$1 is not"
	fi
}

function main(){ #<==主函数
	if [ $# -ne 1 ]
		then
		usage
	fi
	check_url $1
}
main $*
--------------------------------------

#编程流程
	#确定需求 写成小段命令行
	#命令行汇聚成模块 
	#模块转换成函数
	#组合函数


#初版v1.0
#!/bin/bash
#description:tunningSystemFunction
#setEnv
export PATH=$PATH:/bin:/sbin:/usr/sbin
#require root to run this scripts
if [ "$UID" != "0" ];then
	echo "Please run this script by root."
	exit 1
fi

#define cmd var
SERVICE=`which service`
CHKONFIG=`which chkconfig`

function mod_yum(){
	#modify yum path
	if [ -e /etc/yum.repos.d/centos_base.repo ]
		then
		mv /etc/yum.repos.d/centos_base.repo /etc/yum.repos.d/centos_base.repo.BAK&&\
		wget -O /etc/yum.repos.d/centos_base.repo http://mirrors.ayun.com/repo/centos-6.repo 
	fi
}

function close_selinux(){
	#1.close selinux
	sed -i 's/SELINUX=enforcing/SELINUX=disabled' /etc/selinux/chkconfig
	#grep SELINUX=disabled /etc/selinux/config
	setenforce 0 &>/dev/null
	#getenforce
}

function close_iptables(){
	#2.close iptables
	/etc/init.d/ipatbles stop
	/etc/init.d/ipatbles stop
	chkconfig ipatbles off
}

function least_service(){
	#3.least service startup
	chkconfig|egrep "crond|sshd|network|rsyslog|syssta"|awk '{print "chkconfig",$1,"on"}'|bash
	#export LANG=en
	#chkconfig -list|grep 3:on
}

function adduser(){
	#4.add daniel and sudo
	if [ `grep -w daniel /etc/passwd|wc -l` -lt 1 ]
		then
		useradd daniel
		echo 123456|passwd --stdin daniel
		\cp /etc/sudoers /etc/sudoers.ori
		echo "daniel ALL=(ALL) NOPASSWD:ALL " >>/etc/sudoers
		tail -1 /etc/sudoers
		visudo -c &>>/dev/null
	fi
}

function charset(){
	#5.charset config
	cp /etc/sysconfig/i18n /etc/sysconfig/i18n.ori
	echo 'LANG="zh_CN.UTF-8"' >/etc/sysconfig/i18n
	source /etc/sysconfig/i18n
	#cecho $LANG
}

function time_sync(){
	#6.time sync.
	cron=/var/spool/cron/root
	if [ `grep -w "ntpdate" $cron|wc -l` -lt 1 ]
		then
		echo '#time sync by daniel at 20190713' >>$cron
		echo '*/5 * * * * /usr/bin/ntpdate time.nist.gov >/dev/null 2>&1' >>$cron
		crontab -l
	fi
}

function com_line_set(){
	#7.com_line_set
	if [ `egrep "TMOUT|HISTSIZE|ISTFILESIZE" /etc/profile|wcl -l` -lt 3 ]
		then
		echo 'export TMOUT=300' >>/etc/profile
		echo 'exort HISTSIZE=5' >>/etc/profile
		echo 'exort ISTFILESIZE=5' >>/etc/profile
		source /etc/profile
	fi
}

function open_file_set(){
	#8.increase open file.
	if [ `grep 65535 /etc/security/limits.conf|wc -l` -lt 1 ]
		then
		echo '*		- 	nofile 	65535 ' >>/etc/security/limits.conf
		tail -l /etc/security/limts.conf 
	fi
}

function set_kernel(){
	#9.kernel set
		if [ `grep kernel_flag /etc/sysctl.conf|wc -l` -lt 1 ]
			then
			cat >>/etc/sysctl.con<<EOF
			#kernel_flat
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
			net.ipv4.tcp_fin_timeout=12
EOF
		sysctl -p
		fi
}

function init_ssh(){
	#init_ssh
	\cp /etc/sshd/sshd_config /etc/ssh/sshd_config.`date +%Y-%m-%d_%H-%M-%S`
	#sed -i 's%#port 22%port 52113%' /etc/ssh/sshd_config
	sed -i 's%#PermitRootLogin yes%PermitRootLogin no%' /etc/ssh/sshd_config
	sed -i 's%#UseDNS yes%UseDNS no%' /etc/ssh/sshd_config
	/etc/init.d/sshd reload &>/dev/null
}

function update_linux(){
	if [ `rpm -qa lrzsz nmap tree dos2unix nc|wc -l` -le 3 ]
		then
		yum install lrzsz nmap tree dos2unix nc -y
		#yum update -y
	fi
}

main(){
	mod_yum
	close_selinux
	close_iptables
	least_service
	adduser
	charset
	time_sync
	com_line_set
	open_file_set
	set_kernel
	init_ssh
	update_linux
}

main


------------------------------------
#RSYNC脚本
#!/bin/bash
#chkconfig:2345 20 80
if [ $# -ne 1 ]
	then 
	echo $"usage:$0 {start|stop|restart}"
	exit 1
fi

if [ "$1" = "start" ]
	then
	rsync --daemon
	sleep 2 
	if [ `netstat -lntup|grep rsync|wcl -l` -ge 1 ]
		then 
		echo "rsyncd is started"
		exit 0
	fi
elif [ "$1" = "stop" ]
	then
	killall rsync &>/dev/null
	sleep 2
	if [ `netstat -lntup|grep rsync|wc -l` -eq 0 ]
		then
		echo "rsync is stoped"
		exit 0
	fi
elif [ "$1" = "restart" ]
	then
	killall rysnc
	sleep 2
	killpro=`netstat -lntup|grep rsync|wc -l`
	rsync --daemon
	sleep 1
	startpro=`netstat -lntup|grep rsync|wc -l`
	if [ $killpro -eq 0 -a $startpro -ge 1 ]
		then
		echo "rysncd is restarted"
		exit 0
	fi
else
	echo $"usage:$0 {start|stop|restart}"
	eixt 1
fi

---------------------------------------
#!/bin/bash
#chkconfig:2345 20 80
#description:Rsyncd Startup scripts by oldboy
. /etc/init.d/functions

function usage(){
	echo $"usage:$0 {start|stop|restart}"
	exit 1
}

function start(){
	rsync --daemon
	sleep 1
	if [ `netstat -lntup|grep rsync|wc -l` -ge 1 ]
		then
		action "rsyncd is started." /bin/true
	else
		action "rsyncd is started." /bin/true
	fi
}

function stop(){
	killall rsync &>/dev/null
	sleep 2
	if [ `netstat -lntup|grep rsync|wc -l` -eq 0 ]
		then
		acton "rsync is started" /bin/true
	else
		acton "rsync is started" /bin/false
	fi
}

function main(){
	if [ $# -ne 1 ]
		then
		usage
	fi
	if [ "$1" = "start" ]
		then
		start
	elif [ "$1" = "stop" ]
		then
		stop
	elif [ "$1" = "restart" ]
		then
		stop
		sleep 1
		start
	else
		usage
	fi
}

main $*

---------------------------------


































































