#!/bin/bash

export ORACLE_SID=$1

##判断是否为主库
role_pri=$(sqlplus -s / as sysdba <<EOF
set head off
select database_role from v\$database;
exit
EOF
)


ROLE=$(echo $role_pri|awk '{if($0!="")print}')

if [ "${ROLE}" == "PRIMARY" ];then
echo "database_role now is ${ROLE}"
else
echo "database_role now is ${ROLE},exit "
exit 1
fi


##检查通道
DEST_NAME=$(sqlplus -s / as sysdba <<EOF
set head off
select DEST_NAME from v\$archive_dest where dest_name like 'LOG_ARCHIVE_DEST_%' and DESTINATION is not null and dest_name<>'LOG_ARCHIVE_DEST_1';
exit
EOF
)

DESTINATION=$(sqlplus -s / as sysdba <<EOF
set head off
select dest_name||'&'||DESTINATION from v\$archive_dest where dest_name like 'LOG_ARCHIVE_DEST_%' and DESTINATION is not null and dest_name<>'LOG_ARCHIVE_DEST_1';
exit
EOF
)


ERROR1=$(sqlplus -s / as sysdba <<EOF
set head off
select error from v\$archive_dest where dest_name like 'LOG_ARCHIVE_DEST_%' and DESTINATION is not null and dest_name<>'LOG_ARCHIVE_DEST_1';
exit
EOF
)

for i in ${ERROR1[@]}
  do
if [ -n "$i" ];then 
echo "Primary  LOG_ARCHIVE_DEST configuration is wrong,$i,plesse check..."
break 
fi
done


echo "##### Close the log transmission channel `date +'%Y-%m-%d %H:%M:%S'` #####"
##关闭通道

for c in $DESTINATION[@]	
do 
DEST=$(tnsping $(echo $c|cut -d '&' -f 2)|grep 10.232)
DEST_STATE=$(echo $c|cut -d '&' -f 1)

DEST_NAME_NUM=$(echo $c|cut -d '&' -f 1|awk -F '_' '{print $4}')

if [ -z "${DEST}" ];then
DEFER=$(echo "alter system set  log_archive_dest_state_$DEST_NAME_NUM = 'defer';")
    		sqlplus -s / as sysdba <<EOF
    		$DEFER        
    		exit

EOF
echo $DEFER
echo "$DEST_STATE has been deferred..."
##echo $NAME
else

echo -e "$DEST,\nningqiao dg don't operate..."
fi 

sqlplus -s / as sysdba >CHECK_DEST_DEFER.txt <<EOF
	set head off
	select value from v\$spparameter where name='log_archive_dest_state_$DEST_NAME_NUM';
    exit
EOF

done

echo "##### Check the log transmission channel's status `date +'%Y-%m-%d %H:%M:%S'` #####"
DEST_STAT=$(cat CHECK_DEST_DEFER.txt |awk '{printf "%s",$1}')


if [ "${DEST_STAT}" == "defer" ];then
echo "log_archive_dest_state_$DEST_NAME_NUM now is ${DEST_STAT}"
else
echo "log_archive_dest_state_$DEST_NAME_NUM now is ${DEST_STAT},please check now... "
exit 1
fi

