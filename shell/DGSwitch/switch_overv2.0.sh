#!/bin/bash
################################################
#         dg_convert---switchover              #
#         version: 1.00                        #
#         Zhoufeng                             #
#         2019/06/30                           #
################################################

db_unique_name=$1
local_inst1=$2
inst2=$3
export ORACLE_SID=${local_inst1}

switchover()
{   
echo "PRECHECKING......."  
echo "1.check datafile status...."

dbfile_status=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select status from v\\\$datafile_header  where  status not in ('ONLINE','system');
exit;
EOF`

if [ "${dbfile_status}"x = "OFFLINE"x ]
then
echo "error:datafile status offline.."
exit 1
else
echo "checking datafile status passed!"
fi
echo "########################################"

echo "2.check database forcelogging...."
db_forcelog=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select FORCE_LOGGING from v\\\$database  where FORCE_LOGGING!='YES';
exit;
EOF`

if [ "${db_forcelog}"x = "NO"x ]
then
echo "error:database no force_logging .."
exit 1
else
echo "checking database force_logging passed!"
fi
echo "########################################"

echo "3.checking transport_lag"

trans_lag=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select  value from  v\\\$dataguard_stats where name='transport lag' and  VALUE<>'+00 00:00:00';
exit;
EOF`

trans_lag2=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select to_date(TIME_COMPUTED,'MM/DD/YYYY HH24:MI:SS')-to_date(DATUM_TIME,'MM/DD/YYYY HH24:MI:SS') from v$dataguard_stats  where  name='transport lag' and to_date(TIME_COMPUTED,'MM/DD/YYYY HH24:MI:SS')-to_date(DATUM_TIME,'MM/DD/YYYY HH24:MI:SS') <>0;
exit;
EOF
`

if [ "${trans_lag}x" != "x" ] && [ "${trans_lag2}x" != "x" ]
    then
    echo "ERROR:DG transport_lag "${trans_lag}
    exit 1
else
    echo "checking DG transport_lag passed!"
fi
echo "########################################"

echo "4.checking apply_lag"
apply_lag=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select 'ERROR DG apply lag',  VALUE
       from  v\\\$dataguard_stats where name='apply lag'
       and VALUE<>'+00 00:00:00';
exit;
EOF`

if [ "${apply_lag}x" != "x" ]
    then
    echo "ERROR:DG apply_lag "${apply_lag}
    exit 1
   else
   echo "checking apply_lag passed!"
  fi
  
  
echo "########################################"
echo "5.checking datafile header scn...."

dataheader=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
col checkpoint_change# for 9999999999999999999
select distinct checkpoint_change# from v\\\$datafile_header;
exit;
EOF`
echo "The datafile_header scn :"${dataheaer}

datafile=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
col checkpoint_change# for 9999999999999999999
select distinct checkpoint_change# from v\\\$datafile;
exit;
EOF`
echo "The controlfile scn :"${datafile}

if [ "${dataheader}" = "${datafile}" ];
then
echo "checking datafile header scn passed"
else
echo "ERROR: controlfile scn is different from datafile_headers"
echo "the datafile need recovering...."
exit 1
fi
echo "########################################"
echo "6.check database in cluster..."

db_type=`srvctl config database -d ${db_unique_name}|grep -i type|awk -F ':' '{print $2}'|sed -e 's/^[ \t]*//g'`
if [ "${db_type}"x = "RAC"x ];
then
    echo "check database in cluster passed."
else
    echo "error:check database in cluster failed."
    exit 1
fi
echo "########################################"
echo "7.check application session status"
app_session=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select username from v\\\$session where type='USER' and username not in ('PUBLIC','SYS','DBADM','PARTORL','SYSTEM');
exit;
EOF
`
if [ "${app_session}"x = x ];
then
    echo "check application session passed."
else
    echo "error:The application session status check failed."
    exit 1
fi

echo "########################################"

echo "8.check redo logfile directory ...."

cat /dev/null >/tmp/addredodir.sql
`sqlplus -s / as sysdba <<EOF>>/tmp/addredodir.sql
set heading off
select 'alter diskgroup '||substr(member, 2, instr(member,'/')-2)||' add directory ''' ||substr(member, 1, instr(member,'/',-1))|| ''';'from v\\\$logfile;
exit;
EOF`

sqlplus -s / as sysdba<<EOF
@/tmp/addredodir.sql
exit
EOF

echo "########################################"

######################################checking dg status##############################
echo "8.check redo logfile directory ...."
open_staus=`sqlplus -s / as sysdba<<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select open_mode from v\\\$database;
exit;
EOF`

if [ "${open_staus}"x = "READ ONLY WITH APPLY"x ];
then
  echo "The dg status:READ ONLY WITH APPLY"
else
  echo "The dg status error.."
  exit 1
fi

echo "########################################"
echo "9.check current_scn ...."
current_scn=`sqlplus -s / as sysdba<<EOF
set pagesize 0 verify off echo off numwidth 9;
col currnet_scn for 999999999999999999
select current_scn from v\\\$database;
exit;
EOF`

echo "the current_scn is "${current_scn}



echo "##################################"
echo "DG begin to switchover...."
############################begin to convert#######################
echo "1.DG stop applying log..."

sqlplus -s / as sysdba<<EOF
alter database recover managed standby database cancel;
exit
EOF


dg_stop=`sqlplus -s / as sysdba<<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select PROCESS from v\\\$managed_standby where PROCESS='MRP';
exit
EOF`

if [ "${dg_stop}"x = x ];
then
  echo "The database recover managed standby database cancel  success."
else
  echo "The database recover managed standby database cancel  failed."
  echo "checking the database status..."
  exit 1
fi

######################################
echo "create restore point.."

sqlplus -s / as sysdba<<EOF
create restore point zff guarantee flashback database;
exit
EOF

restore_point=`sqlplus -s / as sysdba<<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select name from v\\\$restore_point;
exit
EOF`

if [ "${restore_point}"x = "ZFF"x ];
then
  echo "The restore_point ZFF create sucess.."
else
  echo "The restore_point ZFF create failed.."
  exit 1
fi

#######################################

echo "2.shutdown the another instance..."
/u01/oracle/product/db11gr2/bin/srvctl stop instance -d ${db_unique_name} -i ${inst2}

if [ $? -eq 0 ];
then
  echo "/u01/oracle/product/db11gr2/bin/srvctl stop database -d ${db_unique_name} -i ${inst2} ok..."
else
  echo "/u01/oracle/product/db11gr2/bin/srvctl stop database -d ${db_unique_name} -i ${inst2} failed..."
  echo "switchover stop.."
  exit 1
fi

echo "3.begin to switch dataguard role...."

finish_apply=`sqlplus -s / as sysdba<<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;
exit
EOF`

if [ "${finish_apply}"x = "Database altered."x ];
then
  echo "3.1The DATABASE RECOVER MANAGED STANDBY DATABASE FINISH sucess.."
else
  echo "3.1The DATABASE RECOVER MANAGED STANDBY DATABASE FINISH failed.."
  exit 1
fi


sqlplus -s / as sysdba<<EOF
alter database commit to switchover to primary with session shutdown;
shutdown;
exit
EOF


echo "4.restart database.."
while [ $(ps -ef|grep -v "grep"|grep ${db_unique_name}|grep smon|wc -l) -eq 1 ] 
do 
sleep 10
done

/u01/oracle/product/db11gr2/bin/srvctl start database -d ${db_unique_name}

if [ $? -eq 0 ];
then
  echo "the database cluster start ok..."
else
  echo "the database cluster start failed..."
  echo "switchover stop..please check by manual."
  exit 1
fi


while [ $(ps -ef|grep -v "grep"|grep ${db_unique_name}|grep smon|wc -l) -eq 0 ]
do
sleep 15
done

dbstatus=`sqlplus -s / as sysdba<<EOF
set pagesize 0 verify off echo off numwidth 9;
select distinct status from gv\\\$instance;
exit;
EOF`

open_mode=`sqlplus -s / as sysdba<<EOF
set pagesize 0 verify off echo off numwidth 9;
select open_mode from v\\\$database;
exit;
EOF`


if [[ "${dbstatus}"x = "OPEN"x && "${open_mode}"x = "READ WRITE"x ]];
then
  echo "The database switchover ok."
else
  echo "The database switchover failed.please check database status by manual!!!"
  exit 1
fi

echo "The database switchover success...."


echo "cancel dg_rm_applied script..."
crontab -l >CRONTAB_BAK_FILE 2>/dev/null
crontab -l >CRONTAB_BAK_FILE2 2>/dev/null
sed -i '/dg_rm_applied/d' CRONTAB_BAK_FILE
crontab CRONTAB_BAK_FILE
echo "cancel dg_rm_applied script done..."


}

switchover






