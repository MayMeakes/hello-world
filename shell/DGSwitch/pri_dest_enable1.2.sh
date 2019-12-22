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


echo "##### Check the log transmission channel `date +'%Y-%m-%d %H:%M:%S'` #####"
##检查通道
DEST_NAME=$(sqlplus -s / as sysdba <<EOF
set head off
select DEST_NAME from v\$archive_dest where dest_name like 'LOG_ARCHIVE_DEST_%' and DESTINATION is not null and dest_name<>'LOG_ARCHIVE_DEST_1';
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
echo "Primary LOG_ARCHIVE_DEST configuration is wrong,$i,plesse check..."
break 
fi
done


echo "##### Open the log transmission channel `date +'%Y-%m-%d %H:%M:%S'` #####"
##打开传输通道
for i in ${DEST_NAME[@]}
  do
    DEST_NAME_NUM=$(echo $i |awk  -F '_' '{print $4}')
    DEFER=$(echo "alter system set  log_archive_dest_state_$DEST_NAME_NUM = 'ENABLE';")
	sqlplus -s / as sysdba <<EOF
    $DEFER        
    exit
EOF

    sqlplus -s / as sysdba >CHECK_DEST_ENABLE.txt <<EOF
	set head off
	select value from v\$spparameter where name='log_archive_dest_state_$DEST_NAME_NUM';
    exit
EOF


done


echo "##### Check the log transmission channel's status `date +'%Y-%m-%d %H:%M:%S'` #####"
DEST_STAT=$(cat CHECK_DEST_ENABLE.txt |awk '{printf "%s",$1}')


if [ "${DEST_STAT}" == "ENABLE" ];then
echo "log_archive_dest_state_$DEST_NAME_NUM now is ${DEST_STAT}"
else
echo "log_archive_dest_state_$DEST_NAME_NUM now is ${DEST_STAT},please check now..."
exit 1
fi


sqlplus -s / as sysdba  <<EOF
	set head off
	alter system switch logfile;
	alter system switch logfile;
	alter system switch logfile;
exit
EOF