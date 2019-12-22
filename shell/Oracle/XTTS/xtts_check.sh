#!/bin/bash
#description:xtts_check
#author:meiguiwei
#date:20190716
instance=`ps -ef | grep pmon | grep -v grep | grep -v ASM | grep pmon | awk '{print $NF}'|awk -F '_' '{print $3}'`
for instance_name in $instance
	do
export oracle_sid=$instance_name
echo $oracle_sid
#change parameter dynamic in oracle DB
xtts_check=`sqlplus -s / as sysdba<<EOF
set linesize 200 pagesize 900
promp check start
promp check db time zone
select dbtimezone from dual;
promp

promp check CHARACTERSET
col parameter for a80
col value for a40
select parameter,value from nls_database_parameters where parameter like '%CHARACTERSET%' order by 1;
promp

promp check opatch
col comments for a50
select 'opatch',comments from dba_registry_history order by 1;
promp

promp check db comp
col COMP_NAME for a80
col status for a20
Select comp_name,status from dba_registry order by 1;
promp

promp check compression
select index_name,table_name from dba_indexes where compression='ENABLED' 
and  owner not in  ('ORDSYS', 'WKSYS', 'WK_TEST', 'SYS', 'SYSTEM', 'SYSMAN',
                'DBSNMP', 'ANONYMOUS', 'CTXSYS', 'OLAPSYS', 'WMSYS', 'OUTLN',
                'XDB', 'CTXSYS', 'MDSYS', 'EXFSYS', 'DBADM', 'DBMGR', 'PATROL','ORACLE_OCM',
                'APPQOSSYS','DIP','MGMT_VIEW','APEX_030200','SCOTT','TSMSYS','QCOAGT','PUBLIC','TOAD','PORTAL30','PERFSTAT','PORTAL30_SSO')
order by 1;
promp

promp check iot
Select owner,table_name from dba_tables where iot_type is not null 
and owner not in  ('ORDSYS', 'WKSYS', 'WK_TEST', 'SYS', 'SYSTEM', 'SYSMAN',
                'DBSNMP', 'ANONYMOUS', 'CTXSYS', 'OLAPSYS', 'WMSYS', 'OUTLN',
                'XDB', 'CTXSYS', 'MDSYS', 'EXFSYS', 'DBADM', 'DBMGR', 'PATROL','ORACLE_OCM',
                'APPQOSSYS','DIP','MGMT_VIEW','APEX_030200','SCOTT','TSMSYS','QCOAGT','PUBLIC','TOAD','PORTAL30','PERFSTAT','PORTAL30_SSO')
order by 1;
promp

promp check sys and system obj in user tbs
select table_name, owner, tablespace_name
  from dba_tables
 where tablespace_name not in ('SYSTEM', 'SYSAUX','USERS')
   and owner in ('SYS', 'SYSTEM');
promp

promp check appuser obj in user tbs
select table_name, owner, tablespace_name
  from dba_tables
 where tablespace_name in ('SYSTEM', 'SYSAUX','USERS')
   and owner not in  ('ORDSYS', 'WKSYS', 'WK_TEST', 'SYS', 'SYSTEM', 'SYSMAN',
                'DBSNMP', 'ANONYMOUS', 'CTXSYS', 'OLAPSYS', 'WMSYS', 'OUTLN',
                'XDB', 'CTXSYS', 'MDSYS', 'EXFSYS', 'DBADM', 'DBMGR', 'PATROL','ORACLE_OCM',
                'APPQOSSYS','DIP','MGMT_VIEW','APEX_030200','SCOTT','TSMSYS','QCOAGT','PUBLIC','TOAD','PORTAL30','PERFSTAT','PORTAL30_SSO')
				;
promp

promp check tbs self contain using sysdba
declare
tbsname clob; 
beg number := 0;
cnt number;
begin
 select count(tablespace_name) into cnt from dba_tablespaces 
 where tablespace_name not in ('SYSTEM','SYSAUX','USERS','UNDOTBS1','UNDOTBS2','TEMP','TEMP1','TEMP2','TEMP3','TEMP4','TEMP5','PATROL_TEMP','FFPDARCHIVE_IDS_DATA','FFPDARCHIVE_IDS_INDEX','PATROL');
 for cur in (select tablespace_name from dba_tablespaces 
                 where tablespace_name not in ('SYSTEM','SYSAUX','USERS','UNDOTBS1','UNDOTBS2','TEMP','TEMP1','TEMP2','TEMP3','TEMP4','TEMP5','PATROL_TEMP','FFPDARCHIVE_IDS_DATA','FFPDARCHIVE_IDS_INDEX','PATROL')
             )
 loop
     beg := beg + 1;
     if beg =1 then
         tbsname := cur.tablespace_name||',';
     elsif beg = cnt then
         tbsname := tbsname||cur.tablespace_name;
     else    
         tbsname := tbsname||cur.tablespace_name||',';
     end if;    
     
  end loop; 
  dbms_tts.TRANSPORT_SET_CHECK(tbsname,true,true);   
end;
/

set linesize 300 pagesize 900
SELECT * FROM TRANSPORT_SET_VIOLATIONS;

promp check compatible
show parameter compatible
promp

--alter system set db_files=8192 scope=spfile;
promp check recyclebin
show parameter recyclebin;
promp        

promp check dbf status
Select distinct status from v$datafile;
promp check end 
exit; 
EOF`
echo $xtts_check>/tmp/xtts_check.log
echo 'xtts_check success'
done