#script_name:monitor_slce.sh
#date:20191120
#writer:Daniel

echo  "\n"
echo  "\n"
echo  "\n"
echo  "\n"
echo "=============`date`================="
LOG=/tmp/slce_tmp.log
sqlplusconnect(){
#sqlplus -s sys/changed@slce029_monitor as sysdba >$LOG 2>&1<<EOF
sqlplus -s sys/changed@${SLCE_DB}_monitor as sysdba<<EOF
    set head off
    set pages 0 lines 200
    set feedback off
    SELECT DISTINCT SUBSTR(DOMAIN,2,7) FROM stub.COBRAND_SITE;
EOF
}

dummy_db=`ps -ef | grep pmon | grep -v grep|grep -v ASM | awk '{print $NF}' | cut -c 10- | sort | head -1`
. ~oracle/bin/db $dummy_db


MONITOR_DB=("slce001" "slce006" "slce009" "slcq061" "slce002" "slce003" "slce008")
for SLCE_DB in ${MONITOR_DB[@]}
do
sqlplusconnect >$LOG 2>&1

RC_SLCE=`sqlplus -s sys/changed@${SLCE_DB}_monitor as sysdba<<EOF
    set head off
    set pages 0 lines 200
    set feedback off
    SELECT DISTINCT SUBSTR(DOMAIN,2,7) FROM stub.COBRAND_SITE;
EOF
`

if [ $RC_SLCE = "$SLCE_DB" ]; then
    echo "instance is runing"
elif [ `cat $LOG|grep ORA|wc -l` -ge 1 ] ; then
	echo "Connection failed, try connecting again"
	while true
	do
		sleep 5
		let j++	
		sqlplusconnect >$LOG 2>&1
		if [ `cat $LOG | grep  ORA |wc -l` -le 0 ] ; then
			echo "connect success" 
			break
		#elif [ $j -eq 10 ] && [ `cat $LOG|grep  ORA|wc -l` -ge 1 ] ; then
		elif [ $j -eq 10 ] ; then
			echo "${SLCE_DB}ecommdb is not runing as expected,please handle in time."
			echo "${SLCE_DB}ecommdb is not runing as expected,please handle in time."|mailx -s "WARNING:${SLCE_DB} instance is unavailable," DL-SH-TO-DBA@ebay.com,gmei@stubhub.com,huajin@stubhub.com
			break
		fi
	done
fi

done





