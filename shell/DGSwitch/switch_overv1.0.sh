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
  echo "checking transport_lag"

trans_lag=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select  value from  v\\\$dataguard_stats where name='transport lag' and  VALUE<>'+00 00:00:00';
exit;
EOF`

if [ "${trans_lag}x" != "x" ]
    then
    echo "please check DG ERROR: transport_lag"${trans_lag}
    echo "switchover not continue...."
    exit 1
  fi
echo "checking transport_lag passed!"


echo "checking apply_lag"
apply_lag=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select 'ERROR DG apply lag',  VALUE
       from  v\\\$dataguard_stats where name='apply lag'
       and VALUE<>'+00 00:00:00';
exit;
EOF`

while [ "${apply_lag}x" != "x" ]
do
    echo "please check DG ERROR: apply_lag"${apply_lag}
    echo "waiting applying "
sleep 15
done
echo "checking apply_lag passed!"

echo "checking datafile header...."

dataheaer=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
col checkpoint_change# for 99999999999999999
select distinct checkpoint_change# from v\\\$datafile_header;
exit;
EOF`
echo "The datafile_header scn :"${dataheaer}

datafile=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
col checkpoint_change# for 99999999999999999
select distinct checkpoint_change# from v\\\$datafile;
exit;
EOF`
echo "The controlfile scn :"${datafile}

if [ "${dataheaer}" = "${datafile}" ];
then
echo "checking datafile header passed"
else
echo "The datafile scn is different from datafile_headers"
echo "the datafile need recovering...."
exit 1
fi

echo "check database in cluster..."

db_type=`srvctl config database -d ${db_unique_name}|grep -i type|awk -F ':' '{print $2}'|sed -e 's/^[ \t]*//g'`
if [ "${db_type}"x = "RAC"x ];
then
    echo "The ${db_unique_name} in resource check passed."
else
    echo "The ${db_unique_name} in resource check failed.please check...."
    exit 1
fi


echo "check redo logfile directory ...."

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


######################################checking dg status##############################
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

current_scn=`sqlplus -s / as sysdba<<EOF
set pagesize 0 verify off echo off numwidth 9;
col currnet_scn for 99999999999999999
select current_scn from v\\\$database;
exit;
EOF`

echo "the current_scn is "${current_scn}



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
sleep 15
done

/u01/oracle/product/db11gr2/bin/srvctl start database -d ${db_unique_name}



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
  echo "The database restart ok."
else
  echo "The database restart failed.please check database status by manual!!!"
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






