#!/bin/bash
export ORACLE_BASE=/u01/oracle
export ORACLE_HOME=$ORACLE_BASE/product/db11gr2
export ORACLE_TERM=xterm
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export ORA_NLS10=$ORACLE_HOME/nls/data
export LIBPATH=$ORACLE_HOME/lib:$ORACLE_HOME/ctx/lib
export LD_LIBRARY_PATH=$ORACLE_HOME/lib32:$ORACLE_HOME/lib:$ORACLE_HOME/ctx/lib:$ORACLE_HOME/RDBMS/lib:/lib:/usr/lib
export ORACLE_DOC=$ORACLE_HOME
export PATH=$ORACLE_HOME/OPatch:$ORACLE_HOME/bin::$PATH
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlib
export TMP=/tmp
export TMPDIR=$TMP
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
export NLS_TIMESTAMP_TZ_FORMAT='yyyy-mm-dd hh24:mi:ss.ff'
export EDITOR=vi
set -o vi

USERNAME=`cat /home/oracle/MSEND_SCRIPTS/USER_CONFIG/username.txt`
PASSWD=`cat  /home/oracle/MSEND_SCRIPTS/USER_CONFIG/pwd.txt`
export TOOL_PATH=/home/oracle/chengduDBQUERY

chenduip=`cat chengdu.list`
for ip in $chenduip
do
	#echo "$ip"
	primaryIP=`grep -w "$ip" /home/oracle/MSEND_SCRIPTS/INSTANCE_CHECK/list.txt`
	pri_ip=`echo $primaryIP|awk -F "_" '{print $1}'`
	if [ "$ip" !=  "$pri_ip" ]
		echo $ip>>$TOOL_PATH/dbnotlist.log
		continue
	fi
	#echo "$primaryIP"
	inst=$(echo $primaryIP | awk -F "&" '{print $1}' | awk -F "_" '{print $1":"$2"/"tolower($3)}')
	echo "##### $inst #####"
	echo "##### $inst #####">>$TOOL_PATH/primaryUsernameQuery.log
    usernamec=`sqlplus -s "$USERNAME/$PASSWD"@$inst <<EOF 
    set pagesize 100
    set head off
    set feedback off
    select username from dba_users;
	exit;
EOF`
	echo  $usernamec
	echo  $usernamec|tr ' ' '\n'>>$TOOL_PATH/primaryUsernameQuery.log
done

