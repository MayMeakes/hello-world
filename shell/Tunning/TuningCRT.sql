Tuning.sql

SQL历史执行统计信息：

set lines 300 pages 50
col BEGIN_INTERVAL_TIME for a23
col PLAN_HASH_VALUE for 9999999999
col date_time for a30
col snap_id heading 'SnapId'
col executions_delta heading "No. of exec"
col sql_profile heading "SQL|Profile" for a60 
col date_time heading 'Date time'
col avg_lio heading 'LIO/exec' for 99999999999.99
col avg_cputime_s heading 'CPUTIM/exec' for 9999999.99col avg_etime_s heading 'ETIME/exec' for 9999999.99
col avg_pio heading 'PIO/exec' for 99999999999.99
col avg_row heading 'ROWs/exec' for 9999999.99
SELECT distinct
s.snap_id ,
PLAN_HASH_VALUE,
to_char(s.BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24mi')|| to_char(s.END_INTERVAL_TIME,'_hh24mi') Date_Time,
SQL.executions_delta,
SQL.buffer_gets_delta/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_lio, --SQL.ccwait_delta,
(SQL.cpu_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_cputime_s ,
(SQL.elapsed_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_etime_s,
SQL.DISK_READS_DELTA/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_pio,
SQL.rows_processed_total/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) "ROWs/exec",SQL.sql_profile
FROM
dba_hist_sqlstat SQL,
dba_hist_snapshot s
WHERE
SQL.instance_number =(select instance_number from v$instance)
and SQL.dbid =(select dbid from v$database)
and s.snap_id = SQL.snap_id
AND sql_id in ('&SQLID') order by s.snap_id;

获取执行计划

set linesize 180 pagesize 900
select * from table(dbms_xplan.display_awr('&sqlid','&plan',null,'advanced'));

set linesize 200 pagesize 900
select * from table(dbms_xplan.display_cursor('&1',null,'PEEKED_BINDS')); 
表统计信息

set linesize 200 pagesize 900 
col owner for a15 
col table_name for a20 
col partition_name for a20 
col subPARTITION_NAME for a20 
col PARTITION_POSITION for 9999 
col SUBPARTITION_POSITION for 9999 
select * from dba_tab_statistics where table_name = upper('&table') order by PARTITION_NAME, subPARTITION_NAME; 
根据sql_id查询正在执行的SQL

set linesize 300 pagesize 900
select sql_text from v$sqltext where sql_id='&sqlid' and address = (select address from v$sqltext where sql_id ='&sqlid' and piece=0 and rownum<2) order by piece;
查询会话持续时间

set linesize 200 pagesize 900 
col message for a80
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

select START_TIME,LAST_UPDATE_TIME, TIME_REMAINING, ELAPSED_SECONDS,sofar,totalwork, message from v$session_longops  where sid=&sid and SERIAL#=&siral and sofar<>totalwork order by LAST_UPDATE_TIME;
buffer_gets

set linesize 200                                                                                        
set pagesize 2000                                                                                       
col machine for a20                                                                                     
col username for a20                                                                                    
col event for a40                                                                                       
col FORCE_MATCHING_SIGNATURE for 99999999999999999999999999                                             
select sid, sql_id, FORCE_MATCHING_SIGNATURE, plan_hash_value, event, username, machine, EXECUTIONS,    
avg_lio_mb                                                                                              
  from (select a.sql_id,                                                                                
  b.FORCE_MATCHING_SIGNATURE,                                                                           
               b.plan_hash_value,                                                                       
               a.sid,                                                                                   
               a.event,                                                                                 
               a.username,                                                                              
               a.machine,                                                                               
               b.EXECUTIONS,                                                                            
                      round(case                                                                               
                       when b.EXECUTIONS = 0 then                                                       
                        b.BUFFER_GETS                                                                   
                       else                                                                             
                        b.BUFFER_GETS / b.EXECUTIONS                                                    
                     end * 8 / 1024,                                                                    
                     2) avg_lio_mb                                                                      
          from v$session a, v$sql b                                                                    
         where a.sql_id = b.sql_id                                                                      
           and a.SQL_CHILD_NUMBER = b.CHILD_NUMBER                                                      
           and a.sql_id is not null                                                                     
           and a.status = 'ACTIVE'                                                                      
         order by 9 desc)                                                                               
 where rownum < 10;  
根据等待事件查询具体sql

select sql_id, machine, username, count(*) from v$session where event='&event' 
group by sql_id, machine, username 
order by count(*); 
根据hash_value查找当前执行的SQL

select plan_hash_value, count(*) from v$session s,v$sql q where s.sql_id=q.sql_id group by plan_hash_value;
sql_monitor

set long 999999999
col comm for a300
set lines 300 pages 0
set longchunksize 9000
select dbms_sqltune.REPORT_SQL_MONITOR(SQL_ID=>'&sqlid',TYPE=>'TEXT') as comm from dual;
根据sql_id查询逻辑读

set linesize 300
set pagesize 1000
col BEGIN_INTERVAL_TIME for a23
col PLAN_HASH_VALUE for 9999999999
col date_time for a25
col snap_id heading 'SnapId'
col executions_delta heading "No. of exec"
col sql_profile heading "SQL|Profile" for a7
col date_time heading 'Date time'
col avg_lio heading 'LIO/exec' for 99999999999.99
col avg_cputime_s heading 'CPUTIM/exec' for 9999999.99
col avg_etime_s heading 'ETIME/exec' for 9999999.99
col avg_pio heading 'PIO/exec' for 9999999.99
col avg_row heading 'ROWs/exec' for 9999999.99
SELECT distinct
s.snap_id,
PLAN_HASH_VALUE,
to_char(s.BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24mi')|| to_char(s.END_INTERVAL_TIME,'_hh24mi') Date_Time,
SQL.executions_delta,
SQL.buffer_gets_delta/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_lio,
--SQL.ccwait_delta,
(SQL.cpu_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_cputime_s,
(SQL.elapsed_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_etime_s,
SQL.DISK_READS_DELTA/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_pio,
SQL.rows_processed_total/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_row
--,SQL.sql_profile
FROM
dba_hist_sqlstat SQL,
dba_hist_snapshot s
WHERE
SQL.instance_number =(select instance_number from v$instance)
and SQL.dbid =(select dbid from v$database)
and s.snap_id = SQL.snap_id
AND sql_id in
('&sql_id') order by s.snap_id;
event_sql

set linesize 200 
col username for a13 
col event for a35 
col program for a20 truncate 
col cpu_p for 99.99 
select ta.*,round(ta.cpu_time/tb.total_cpu * 100,1) cpu_usage from 
(select 
 s.username,s.program,s.event,s.sql_id,sum(trunc(m.CPU)) CPU_TIME,count(*) sum 
        --,sum(m.PHYSICAL_READS)  P_READ,sum(LOGICAL_READS)   L_READ, 
  from v$sessmetric m ,v$session s 
where ( m.PHYSICAL_READS >100 
       or m.CPU>100 
       or m.LOGICAL_READS >100) 
       and m.SESSION_ID = s.SID 
       and m.SESSION_SERIAL_NUM = 
 s.SERIAL# 
       and s.status = 'ACTIVE' 
       and username is not null 
group by 
 s.username,s.program,s.event,s.sql_id 
order by 5 desc) ta,(select sum(cpu)  
 total_cpu from v$sessmetric) tb 
where rownum < 11; 
根据等待事件查询SQL信息

select /*+rule*/ b.inst_id,a.sid,a.serial#,a.username,a.machine,a.program,a.sql_id,a.sql_hash_value,b.event,b.SECONDS_IN_WAIT,sysdate,a.status
  from gv$session a, gv$session_wait b
 where a.sid = b.sid
   and a.inst_id = b.inst_id 
   and (b.event = 'kksfbc child completion'
   or b.event like 'enq%'
   or b.event like 'latch%'
   or b.event like 'cursor%'
   or b.event like 'library%'
   or b.event like 'log file switch%'
   or b.event like 'resmgr%'
   or b.event like 'row cache%'
       );
索引统计信息

select LAST_ANALYZED,INDEX_NAME,status  from dba_indexes where INDEX_NAME=upper('&IDX_NAME');
top_sql

set linesize 200
set pagesize 20
col "CPU + CPU Wait%" for 999
col "User I/O%" for 999
col "Application%" for 999
col "Network%" for 999
col "Concurrency%" for 999
col "Configuration%" for 999
col "Other%" for 999
col "System I/O%" for 999
col "Commit%" for 999
col "Queueing%" for 999
col "Administrative%" for 999
col "Scheduler%" for 999
col "total%" for 999
select *
from (select sql_id,
round("CPU + CPU Wait" / sum(sql_total) over() * 100, 2) as "CPU + CPU Wait%",
round("User I/O" / sum(sql_total) over() * 100, 2) as "User I/O%",
round("Application" / sum(sql_total) over() * 100, 2) as "Application%",
round("Network" / sum(sql_total) over() * 100, 2) as "Network%",
round("Concurrency" / sum(sql_total) over() * 100, 2) as "Concurrency%",
round("Configuration" / sum(sql_total) over() * 100, 2) as "Configuration%",
round("Other" / sum(sql_total) over() * 100, 2) as "Other%",
round("System I/O" / sum(sql_total) over() * 100, 2) as "System I/O%",
round("Commit" / sum(sql_total) over() * 100, 2) as "Commit%",
round("Queueing" / sum(sql_total) over() * 100, 2) as "Queueing%",
round("Administrative" / sum(sql_total) over() * 100, 2) as "Administrative%",
round("Scheduler" / sum(sql_total) over() * 100, 2) as "Scheduler%",
round(RATIO_TO_REPORT(sql_total) over()*100,2) as "total%"
from (select sql_id,
"CPU + CPU Wait",
"User I/O",
"Application",
"Network",
"Concurrency",
"Configuration",
"Other",
"System I/O",
"Commit",
"Queueing",
"Administrative",
"Scheduler",
("CPU + CPU Wait" + "User I/O" + "Application" +
"Network" + "Concurrency" + "Configuration" + "Other" +
"System I/O" + "Commit" + "Queueing" +
"Administrative" + "Scheduler") sql_total
from (select ash.sql_id,
sum(decode(ash.session_state, 'ON CPU', 1, 0)) "CPU + CPU Wait",
sum(decode(ash.WAIT_CLASS, 'User I/O', 1, 0)) "User I/O",
sum(decode(ash.WAIT_CLASS, 'Application', 1, 0)) "Application",
sum(decode(ash.WAIT_CLASS, 'Network', 1, 0)) "Network",
sum(decode(ash.WAIT_CLASS, 'Concurrency', 1, 0)) "Concurrency",
sum(decode(ash.WAIT_CLASS,
'Configuration',
1,
0)) "Configuration",
sum(decode(ash.WAIT_CLASS, 'Other', 1, 0)) "Other",
sum(decode(ash.WAIT_CLASS, 'System I/O', 1, 0)) "System I/O",
sum(decode(ash.WAIT_CLASS, 'Commit', 1, 0)) "Commit",
sum(decode(ash.WAIT_CLASS, 'Queueing', 1, 0)) "Queueing",
sum(decode(ash.WAIT_CLASS,
'Administrative',
1,
0)) "Administrative",
sum(decode(ash.WAIT_CLASS, 'Scheduler', 1, 0)) "Scheduler"
from V$ACTIVE_SESSION_HISTORY ash
where sample_time > sysdate - 5 / 24 / 60
group by ash.sql_id)
where sql_id is not null
order by 14 desc))
where rownum < 11;   


    
表统计信息

select owner, PARTITIONED,num_rows ,last_analyzed from dba_tables where table_name=upper('&1');
open_cursor

set linesize 300
col user_name for a20
col sql_id for a13
col cursor_type for a21
select user_name,sql_id,sql_text,CURSOR_TYPE
  from v$open_cursor where sid=nvl(&sid,sid);
get_bind

set linesize 300
col sql_id for a14
col name for a20
col datatype_string for a15
col value_string for a20
select snap_id,instance_number,sql_id,name,position,datatype_string,value_string,last_captured from dba_hist_sqlbind  where        sql_id = nvl('&sql_id', sql_id)   and snap_id >= (nvl('&bid', snap_id))   and snap_id <= (nvl('&eid', snap_id))     order by LAST_CAPTURED;  
根据sid查找会话的等待事件

set linesize 300
select sid,event,total_waits,time_waited from v$session_event where sid='&sid' order by total_waits;
display_cursor ALLSTATS LAST

select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));
cpu_sql

set linesize 1000
set pagesize 900
col username for a10
col event for a35
col program for a20 truncate
col module for a25
col cpu_p for 99.99
select ta.*,round(ta.cpu_time/tb.total_cpu * 100,1) cpu_usage from
(select s.username,s.program,s.module,s.action,s.event,s.sql_id,sum(trunc(m.CPU)) CPU_TIME,count(*) sum
        --,sum(m.PHYSICAL_READS) P_READ,sum(LOGICAL_READS) L_READ,
  from v$sessmetric m ,v$session s
where ( m.PHYSICAL_READS >100
       or m.CPU>100
       or m.LOGICAL_READS >100)
       and m.SESSION_ID = s.SID
       and m.SESSION_SERIAL_NUM = s.SERIAL#
       and s.status = 'ACTIVE'
       and username is not null
group by s.username,s.program,s.module,s.action,s.event,s.sql_id
order by 5 desc) ta,(select sum(cpu) total_cpu from v$sessmetric) tb
where rownum < 11;