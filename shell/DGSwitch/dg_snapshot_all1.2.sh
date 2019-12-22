#!/bin/bash

export ORACLE_SID=$1

export TIME_EXEC=$2

dg_convert(){
starttime=`date +'%Y-%m-%d %H:%M:%S'`
echo "Start time is $starttime..."

##判断是否为DG库
role_dg=$(sqlplus -s / as sysdba <<EOF
set head off
select database_role from v\$database;
exit
EOF
)

ROLE=$(echo $role_dg|awk '{if($0!="")print}')

if [ "${ROLE}" == "PHYSICAL STANDBY" ];then
echo "database_role now is ${ROLE}"
else
echo "database_role now is ${ROLE},exit "
exit 1
fi


##建立闪回区
DESTINATION=$(sqlplus -s / as sysdba <<EOF
set head off
select DESTINATION from v\$archive_dest where dest_name='LOG_ARCHIVE_DEST_1';
exit
EOF
)



DEST=$(echo $DESTINATION |awk '{printf "%s",$1}')
DEST_NEW=${DEST%*/}

cd ${DEST_NEW}

echo "##### create flashback directory "fra1" `date +'%Y-%m-%d %H:%M:%S'` #####"
cd ${DEST_NEW}
if [ ! -d "fra1" ];then
        cd ${DEST_NEW}
        mkdir fra1 2>/dev/null &
        if [ $? -eq 0 ];then
  echo "create directory fra1 successfully"
  else 
  echo "create directory fra1 failed,please check..."
  exit 1
  fi
else 
echo "directory fra1 has been exists"
cd fra1
touch test.txt
  if [ $? -eq 0 ];then
  echo "you can use this directory fra1"
  else 
  echo "Directory's permission is not oracle:oinstall, Please check..."
  exit 1
  fi
fi

#ls -d  $DEST_NEW/fra1


echo "#### Get original  archive path `date +'%Y-%m-%d %H:%M:%S'` #####"
ARC_DEST=$(
sqlplus -s / as sysdba <<EOF 
set head off
select value from v\$spparameter where name='log_archive_dest_1';
exit
EOF
)

ARC_DEST_1=` echo ${ARC_DEST} |awk '{if($0!="")print}' `

echo ${ARC_DEST_1} >ARC_DEST.txt

echo "original archive path is ${ARC_DEST_1}"



echo "##### Set flashback point directory `date +'%Y-%m-%d %H:%M:%S'` #####"
sqlplus -s / as sysdba <<EOF
set head off
alter system set db_recovery_file_dest_size=100G scope=both;
alter system set db_recovery_file_dest='$DEST_NEW/fra1' scope=both;
alter system set log_archive_dest_1='LOCATION=$DEST_NEW/fra1' scope=both;
exit
EOF



if [ $? -eq 0 ];then
echo "db_recovery_file_dest='${DEST_NEW}/fra1' successfully"
else
echo "db_recovery_file_dest='${DEST_NEW}/fra1' failed,please check..."
exit 1
fi



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
echo "DG zb_sec LOG_ARCHIVE_DEST configuration is wrong,$i,plesse check... "
break 
fi
done


echo "##### Close the log transmission channel `date +'%Y-%m-%d %H:%M:%S'` #####"
##关闭通道
for i in ${DEST_NAME[@]}
  do
    DEST_NAME_NUM=$(echo $i |awk  -F '_' '{print $4}')
    DEFER=$(echo "alter system set  log_archive_dest_state_$DEST_NAME_NUM = 'defer';")
    sqlplus -s / as sysdba <<EOF
    $DEFER        
    exit
EOF
done


echo "##### Closing the log application `date +'%Y-%m-%d %H:%M:%S'` #####"
##关闭日志应用
sqlplus -s / as sysdba <<EOF
set head off
alter database recover managed standby database cancel;
exit
EOF



echo "##### Check the secondary DG application status `date +'%Y-%m-%d %H:%M:%S'` #####"
#检查二级DG应用状态
for c in ${DEST_NAME[@]}
do
STATUS_err=$(sqlplus -s / as sysdba <<EOF
set head off
select status from v\$archive_dest where dest_name='$c';
exit
EOF
)


STATUS=$(echo $STATUS_err |awk '{printf "%s",$1}')

        if [ "$STATUS" == "DEFERRED" ];then 
                echo "$c has already been $STATUS"
        else 
                echo "$c has not been $STATUS"
                continue
        fi

done



echo "##### Start to shutdown instance `date +'%Y-%m-%d %H:%M:%S'` #####"
##停库
sqlplus -s / as sysdba <<EOF 
shutdown immediate;
startup mount;
exit;
EOF



if [ $? -eq 0 ];then
echo "shutdown and mount successfully"
else
echo "shutdown and mount failed,please check"
exit 1
fi


echo "##### Create flashback point,convert database to snapshot `date +'%Y-%m-%d %H:%M:%S'` #####"
##新建闪回点,打开到snapshot模式
sqlplus -s / as sysdba <<EOF
set head off
create restore point beforeswitch guarantee flashback database;
alter database convert to snapshot standby;
exit
EOF


##检查dg库此时状态
#open_mode=$(sqlplus -s / as sysdba <<EOF
#set head off
#select open_mode from v\$database;
#exit
#EOF
#)


echo "##### Start to open the instance `date +'%Y-%m-%d %H:%M:%S'` #####"
sqlplus -s / as sysdba <<EOF
set head off
alter database open; 
exit
EOF


if [ $? -eq 0 ];then
echo "open database successfully"
else
echo "open database failed,please check"
exit 1
fi

echo "##### Check database role `date +'%Y-%m-%d %H:%M:%S'` #####"
##确认状态为SNAPSHOT STANDBY
DATABASE_ROLE=$(sqlplus -s / as sysdba <<EOF
set head off
select database_role from v\$database;
exit
EOF
)

DATABASE_ROLE=$(echo $DATABASE_ROLE |awk '{if($0!="")print}')

if [ "${DATABASE_ROLE}" == "SNAPSHOT STANDBY" ];then
echo "${DATABASE_ROLE} successfully"
##手工切日志
sqlplus -s / as sysdba <<EOF
set head off
alter system switch logfile;
alter system switch logfile;
exit
EOF

else
echo "snapshot failed,now database role is $DATABASE_ROLE,please check..."
exit 1
fi
}



dg_return(){
echo "##### Check database role `date +'%Y-%m-%d %H:%M:%S'` #####"
##确认状态为SNAPSHOT STANDBY
DATABASE_ROLE=$(sqlplus -s / as sysdba <<EOF
set head off
select database_role from v\$database;
exit
EOF
)

ROLE=$(echo $DATABASE_ROLE|awk '{if($0!="")print}')


if [ "$ROLE" == "SNAPSHOT STANDBY" ];then

echo $ROLE

echo "##### Start to shutdown instance,convert database to PHYSICAL,then Start to shutdown instance again `date +'%Y-%m-%d %H:%M:%S'`#####"
sqlplus -s / as sysdba <<EOF
set head off
shutdown immediate;
startup mount;
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;
shut abort;

exit
EOF
else 
echo "please check database role!!"
exit 1
fi


if [ $? -eq 0 ];then
echo "shutdown successfully"
else
echo "shutdown failed,please check"
exit 1
fi


echo "##### Drop flashback point,open database read-only `date +'%Y-%m-%d %H:%M:%S'` #####"
sqlplus -s / as sysdba <<EOF
set head off
startup mount;
drop restore point beforeswitch;
alter database open read only;
exit
EOF



echo "##### Check database open_mode `date +'%Y-%m-%d %H:%M:%S'` #####"
OPEN_MODE=$(sqlplus -s / as sysdba <<EOF
set head off
select open_mode from v\$database;
exit
EOF
)

MODE=$(echo $OPEN_MODE|sed 's/\n//g')
MODE_new=$(echo $MODE|awk '{if($0!="")print}')

if [ "${MODE_new}" == "READ ONLY" ];then
echo "database now ${MODE_new}"
else
echo "database now ${MODE_new}"
exit 1
fi


echo "##### Set original archive path `date +'%Y-%m-%d %H:%M:%S'` #####"
ARC_DEST_1=` cat ARC_DEST.txt `
sqlplus -s / as sysdba <<EOF
set head off
alter system set log_archive_dest_1='${ARC_DEST_1}';
exit
EOF

if [ $? -eq 0 ];then
echo "Set original archive path ${ARC_DEST_1} successfully "
else
echo "Set original archive path ${ARC_DEST_1} failed,please check it..."
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
echo "DG zb_sec LOG_ARCHIVE_DEST configuration is wrong,$i,plesse check..."
break 
fi
done


echo "##### Delete flashback log `date +'%Y-%m-%d %H:%M:%S'` #####"

sqlplus -s / as sysdba >DEST.txt <<EOF
set head off
select value from v\$spparameter where name='db_recovery_file_dest';
exit
EOF


DEST=$(cat DEST.txt |awk '{if($0!="")print}')

##cd ${DEST}

if [ -d "${DEST}" ];then
cd ${DEST}
ls -l *.arc
    if [ $? -eq 0 ];then
        echo "Flashback log exists"
        rm  *.arc
      echo "Delete flashback log successfully"
    else
      echo "Delete flashback log failed,please check if log exists"
      exit 1
    fi
else 
echo "Please check flashback direcory..."
exit 1
fi


echo "##### Delete backup piece `date +'%Y-%m-%d %H:%M:%S'` #####"
rman target / <<EOF
run
{
crosscheck archivelog all;
delete noprompt expired archivelog all;
}
EOF


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
done


echo "##### Set flashback point directory empty `date +'%Y-%m-%d %H:%M:%S'` #####"
sqlplus -s / as sysdba <<EOF
set head off
alter system set db_recovery_file_dest='' scope=both;
alter system reset db_recovery_file_dest_size scope=spfile;
shutdown immediate;
startup
exit
EOF


echo "##### Open the log application `date +'%Y-%m-%d %H:%M:%S'` #####"
##开启日志应用
sqlplus -s / as sysdba <<EOF
set head off
alter database recover managed standby database disconnect from session using current logfile;
exit
EOF


echo "##### Check DG status `date +'%Y-%m-%d %H:%M:%S'` #####"
##检查一级DG状态
sqlplus -s / as sysdba <<EOF
set head off
select PROCESS,STATUS,PID,SEQUENCE#,BLOCK# ,THREAD#,DELAY_MINS from  v\$managed_standby;
exit
EOF


}

dg_convert

# while loops
#已经是闪回模式，开始计时


DESTINATION=$(sqlplus -s / as sysdba <<EOF
set head off
select DESTINATION from v\$archive_dest where dest_name='LOG_ARCHIVE_DEST_1';
exit
EOF
)

DEST=$(echo $DESTINATION |awk '{printf "%s",$1}')
DEST_NEW=${DEST%*/}


ARC_USE=$(echo $DEST_NEW|awk -F '/' '{print $3}')
INSTANCE_USE=$(echo $DEST_NEW|awk -F '/' '{print $2}')

echo "Start waiting ${TIME_EXEC} `date +'%Y-%m-%d %H:%M:%S'` "
export SLEEP_check=0
while :
do
        sleep 60
        SLEEP_check=$(($SLEEP_check+60))
        if [ ${SLEEP_check} -lt ${TIME_EXEC} ];then
                echo "dg convert shell is running"
                USE=$( df -Ph|grep ${ARC_USE}|grep ${INSTANCE_USE}|awk -F ' ' '{print $5}'|awk -F '%' '{print $1}')
                if [ "${USE}" -lt "85" ];then
                        echo "archive directory space is enough,${USE}%..."
                        continue
                else
                        echo "archive directory has been used ${USE}%,not enough space..."
                        break
                fi
        else
                echo "dg convert shell has been executed ${TIME_EXEC}"
                break
        fi
done

#回切
dg_return

