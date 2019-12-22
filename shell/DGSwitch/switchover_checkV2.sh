#!/bin/bash
################################################
#         switchover_check                     #
#         version: 1.00                        #
#         Zhoufeng                             #
#         2019/07/03                           #
################################################
#以下版本为RAC环境下DG的切换

#Ver2.0 add check block_corruption、apply_lag
#Ver2.1 add transpot lag check

inst_name=$1
db_unique_name=$2

export ORACLE_SID=${inst_name}

check_dgswitch()
{
echo "1.check datafile status...."

dbfile_status=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select status from v\\\$datafile_header  where  status not in ('ONLINE','system');
exit;
EOF`

if [ "${dbfile_status}"x = "OFFLINE"x ]
then
echo "error:datafile status offline.."
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
else
echo "checking database force_logging passed!"
fi
echo "########################################"

echo "3.check database block_corruption..."
db_corruption=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select FILE# from v\\\$database_block_corruption;
exit;
EOF`

if [ "${db_corruption}"x = x ]
then
echo "checking database block_corruption passed!"
else
echo "error:database block_corruption..."
fi
echo "########################################"

echo "4.checking transport_lag"

trans_lag=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select  value from  v\\\$dataguard_stats where name='transport lag' and  VALUE<>'+00 00:00:00';
exit;
EOF`

trans_lag2=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select to_date(TIME_COMPUTED,'MM/DD/YYYY HH24:MI:SS')-to_date(DATUM_TIME,'MM/DD/YYYY HH24:MI:SS') from v\\\$dataguard_stats  where  name='transport lag' and to_date(TIME_COMPUTED,'MM/DD/YYYY HH24:MI:SS')-to_date(DATUM_TIME,'MM/DD/YYYY HH24:MI:SS') <>0;
exit;
EOF`

trans_lag3=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select DATUM_TIME  from v\\\$dataguard_stats  where  name='transport lag';
exit;
EOF`

trans_lag4=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select  value from  v\\\$dataguard_stats where name='transport lag';
exit;
EOF`

trans_lag5=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select sysdate-to_date(DATUM_TIME,'MM/DD/YYYY HH24:MI:SS') from v\\\$dataguard_stats  where  name='transport lag' and sysdate-to_date(DATUM_TIME,'MM/DD/YYYY HH24:MI:SS') <>0;
exit;
EOF`

if [ "${trans_lag}"x = x ] && [ "${trans_lag2}"x = x ] && [ "${trans_lag5}"x = x ]
    then
    echo "checking DG transport_lag passed!"
else
    echo "ERROR:DG transport_lag "${trans_lag4}
    echo "At ${trans_lag3},the dg stop receiving archivelog from primary,and the transport lag display ${trans_lag2}!!"
fi

sqlplus -s / as sysdba <<EOF
col value for a30
set lines 30000 pagesize 3000 feedback off  verify off echo off numwidth 9
select 'DG transport lag', VALUE ,TIME_COMPUTED,DATUM_TIME,sysdate from  v\$dataguard_stats where name='transport lag';
exit;
EOF



echo "########################################"

echo "5.checking apply_lag"
apply_lag=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
select 'ERROR DG apply lag',  VALUE
       from  v\\\$dataguard_stats where name='apply lag'
       and VALUE<>'+00 00:00:00';
exit;
EOF`


if [ "${apply_lag}"x = x ]
    then
    echo "checking apply_lag passed!"
    else
   echo "ERROR:DG apply_lag "${apply_lag}
  fi

sqlplus -s / as sysdba <<EOF
col value for a30
set lines 30000 pagesize 3000 feedback off  verify off echo off numwidth 9
select 'DG apply lag', VALUE ,TIME_COMPUTED,DATUM_TIME,sysdate from  v\$dataguard_stats where name='apply lag';
exit;
EOF
  
  
echo "########################################"
echo "6.checking datafile header scn...."

dataheader=`sqlplus -s / as sysdba <<EOF
set heading off feedback off pagesize 0 verify off echo off numwidth 9
col checkpoint_change# for 9999999999999999999
select distinct checkpoint_change# from v\\\$datafile_header;
exit;
EOF`
echo "The datafile_header scn :"${dataheader}

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
fi
echo "########################################"
echo "7.check database in cluster..."

db_type=`srvctl config database -d ${db_unique_name}|grep -i type|awk -F ':' '{print $2}'|sed -e 's/^[ \t]*//g'`
if [ "${db_type}"x = "RAC"x ];
then
    echo "check database in cluster passed."
else
    echo "error:check database in cluster failed."
fi
echo "########################################"
echo "8.check application session status"
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
fi

echo "switchover prechecking finish!"
}
check_dgswitch