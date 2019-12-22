
SQL语句优化分析处理手册

 

Oracle SQL语句优化分析处理手册

 

第一部分：SQL语句优化分析处理手册

0.表连接的基础知识
0.1.访问表的方法：
Ø 全表扫描（TABLE ACCESS FULL）:（多块读）是指从第一个块扫描到该表的高水位线的所有的数据块；
Ø Rowid扫描：是指根据数据所在的rowid去扫描对应表的相关数据；
0.2.访问索引的方法：
Ø 索引唯一扫描（INDEX UNION SCAN）：是指where条件中是等值查询的目标SQL，返回一条结果的扫描；
Ø 索引范围扫描（INDEX RANGE SCAN）：是指where条件中是范围查询的目标SQL，可能会返回多条数据；
Ø 索引全扫描（INDEX FULL SCAN）：（结果有序）是指要扫描目标索引所有叶子块的所有所有行；
Ø 索引快速全扫描（INDEX FAST FULL SCAN）: （多块读）是指要扫描目标索引所有叶子块的所有所有行； 
Ø 索引跳跃式扫描（INDEX SKIP SCAN）：是指where条件中没有对目标索引的前导列指定查询条件但同时又对该索引的非前导列指定了查询条件的目标SQL依然可以使用该索引（大多数情况，是该执行计划中缺少更加合适的索引）；
0.3.表连接的类型：
Ø 内连接(INNER  JOIN ):指表连接的结果只包含那些完全满足连接条件的记录；
Ø 外连接(OUTER  JOIN ):指表连接的结果除了包含那些完全满足连接条件的记录之外还包含驱动表中所有不满足该连接条件的记录；
0.4.表连接的方法：
Ø 排序合并（SORT  MERGE  JOIN）：是指一种两张表在做表连接时用排序操作（sort）和合并操作（merge）来得到连接结果集的表连接方法；
Ø 嵌套循环（NESTED  LOOPS  JOIN）：是指一种两张表在做表连接时依靠两层嵌套循环来得到连接结果集的表连接方法；
Ø 哈希连接（HASH  JOIN）：是指一种两张表在做表连接时依靠哈希运算来得到连接结果集的表连接方法；
Ø 笛卡尔积连接（MERGE  JOIN  CARTESIAN）：是指一种两张表在做表连接时没有任何连接条件的表连接方法；
0.5.反连接(ANTI JOIN) ：是指一种两张表在做表连接时取那些不满足连接条件的记录；
0.6.半连接(SEMI JOIN) ：（去重）是指一种两张表在做表连接时取那些返回第一张表满足条件的记录；
0.7.星型连接（STAR JOIN）：是指一种单个事实表（fact table）和多个维度表（dimension table）之间的连接；通常适用于数据仓库类型的应用；
1.获取对应的数据库IP、INSTANCE_NAME、SQL_ID及设置相关全局参数
1.1根据cpu告警信息获取对应的数据库IP、INSTANCE_NAME、SQL_ID
1.1.1.告警内容
[田林中心]集团2009版集中资金管理平台系统,产险2007版车险承保业务系统[10.190.57.57][主机名：cxcbdb3],CPU使用率为98.76%,告警级别[低]。 实时性能：http://itom.hq.cpic.com/realtime/realtime!show?eventId=939083

1.1.2.查看告警信息
Cpu告警需要登录该系统进行查看，使用命令vmstat 1

其中cpu中的us表示用户使用的cpu占比，sy表示系统使用的cpu占比，id表示空闲的cpu占比，wa表示等待io的cpu占比。当id列的值非常少时，需要关注

 
1.1.3.CPU告警原因分析

Cpu告警原因大致可以分为数据库进程导致和主机进程导致

当使用top或者topas命令查看时，如果排名前面的都是oracle用户发起的，则判断是数据库进程导致，需要查看数据库中的高消耗语句

当排名靠前的是其他用户时，将该告警钉钉通知数据库组所有人，并根据需要将工单转派至其他组。

 

1.1.4.查询数据库是否有堵塞

查询数据库是否有堵塞：

select (select username from v$session where sid=a.sid) blocker,a.sid, 'is blocking', (select username from v$session where sid=b.sid) blocked,b.sid from v$lock a,v$lock b where a.block=1 and b.request>0 and a.id1=b.id1 and a.id2=b.id2;


查询堵塞源：

select ppath, sid, event, username, machine, case when row_wait_obj# <> -1 then sys.dbms_rowid.rowid_create(1, (select data_object_id from dba_objects where object_id = row_wait_obj#), row_wait_file#, row_wait_block#, row_wait_row#) end row_id from (select lv, ppath, sid, event, username, machine, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#, row_number() over(partition by sid order by lv desc) rn from (select level lv, connect_by_isleaf isleaf, sys_connect_by_path(sid, '=>') ppath, bsid, sid, event, username, machine, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row# from (select inst_id || '_' || sid sid, blocking_instance || '_' || blocking_session bsid, event, username, machine, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row# from gv$session) connect by prior sid = bsid) where isleaf = 1 and lv > 1) where rn = 1;
 


查看对应SID的SQL_ID信息：

select prev_sql_id,sql_id,p.spid,s.process,s.program,s.machine,s.osuser,s.status,s.event,s.logon_time,s.last_call_et    from gv$session s, gv$process p where s.paddr=p.addr and s.sid=&sid；

 

 

1.1.5.查询CPU top10的语句

set linesize 200
col username for a15
col event for a35
col program for a20
col cpu_p for 99.99
select ta.*, round(ta.cpu_time / tb.total_cpu * 100, 1) cpu_usage from (select s.username, s.program, s.event, s.sql_id, sum(trunc(m.cpu)) cpu_time, count(*) sum from v$sessmetric m, v$session s where (m.physical_reads > 100 or m.cpu > 100 or m.logical_reads > 100) and m.session_id = s.sid and m.session_serial_num = s.serial# and s.status = 'ACTIVE' and username is not null group by s.username, s.program, s.event, s.sql_id order by 5 desc) ta, (select sum(cpu) total_cpu from v$sessmetric) tb where rownum < 11;

 

 

1.1.5.根据QMonitor查询TOP SQL
根据QMonitor（http://10.190.20.86:8080）查询对应IP地址的CPU 告警信息情况，然后查对应的时间段的高消耗SQL语句，并获取对应的SQL语句进行分析；

CPU 告警信息情况：
CPU 告警信息对应时间段的TOP  SQL信息：



1.2根据业务应用开发人员提供的SQL语句定位对应的sql_id

例：根据SQL语句中的表名或者关键字获取sql_id；

select sql_id ,sql_text from dba_hist_sqltext where sql_text like '&sql_text';

 

SQL_ID        SQL_TEXT
------------- --------------------------------------------------------------------------------
cd7ftyrjgvasy MERGE /*+parallel (4)*/ INTO BS_PROCMAIN A
              USING ML_QW_PROCMAIN_03 B
                ON (A.POLICYNO = B.POLICYNO
                AND A.CompanyCode = B.CompanyCode )
              WHEN MATCHED THEN
                 UPDATE SET  A.PayTimes = GREATEST(NVL(A.P
              ayTimes,B.PayTimes),NVL(B.PayTimes,A.Pay
              Times))
              WHEN NOT MATCHED THEN
                  INSERT
                  (
                      CompanyCode,
                      PolicyNo,
                      PayTimes
                  )
                  VALUES (
                       B.CompanyCode,
                       B.PolicyNo,
                       B.PayTimes
                 )

 

1.3根据SQL_ID获取所属的用户名

col OBJECT_OWNER for a15
col OBJECT_TYPE for a20
select t.SQL_ID,t.OBJECT_OWNER,t.OBJECT_NAME,t.OBJECT_TYPE FROM  V$sql_Plan T WHERE T.SQL_ID='&SQL_ID';

SQL_ID        OBJECT_OWNER    OBJECT_NAME               OBJECT_TYPE
------------- --------------- ------------------------- --------------------
cd7ftyrjgvasy
cd7ftyrjgvasy CXBDDJ          BS_PROCMAIN
cd7ftyrjgvasy
cd7ftyrjgvasy SYS             :TQ10000
cd7ftyrjgvasy
cd7ftyrjgvasy
cd7ftyrjgvasy
cd7ftyrjgvasy CXBDDJ          ML_QW_PROCMAIN_03         TABLE (TEMP)
cd7ftyrjgvasy CXBDDJ          BS_PROCMAIN               TABLE
cd7ftyrjgvasy CXBDDJ          PK_BSMAIN                 INDEX (UNIQUE)
 

1.4设置相关全局参数

alter session set statistics_level=all;
alter session set current_schema=&1;
SQL> alter session set current_schema=&1;
Enter value for 1: CXBDDJ
old   1: alter session set current_schema=&1
new   1: alter session set current_schema=CXBDDJ

Session altered.

Elapsed: 00:00:00.01

SQL>

2.根据SQL_ID获取SQL的执行计划信息
2.1根据SQL_ID获取历史的执行计划的相关信息

set lines 30000 pages 30000                                                                               
col BEGIN_INTERVAL_TIME for a23                                                                           
col PLAN_HASH_VALUE for 9999999999                                                                        
col date_time for a20                                                                                     
col snap_id heading 'SnapId'                                                                              
col executions_delta heading "No. of exec"                                                                
col sql_profile heading "SQL|Profile" for a7                                                              
col date_time heading 'Date time'                                                                         
col avg_lio heading 'LIO/exec' for 99999999999.99                                                         
col avg_cputime_s heading 'CPUTIM/exec' for 9999999.99                                                    
col avg_etime_s heading 'ETIME/exec' for 9999999.99                                                       
col avg_pio heading 'PIO/exec' for 9999999.99                                                             
col avg_row heading 'ROWs/exec' for 9999999.99  
select distinct s.snap_id, plan_hash_value, to_char(s.begin_interval_time, 'mm/dd/yy_hh24mi') || to_char(s.end_interval_time, '_hh24mi') date_time, sql.executions_delta, sql.buffer_gets_delta / decode(nvl(sql.executions_delta, 0), 0, 1, sql.executions_delta) avg_lio, (sql.cpu_time_delta / 1000000) / decode(nvl(sql.executions_delta, 0), 0, 1, sql.executions_delta) avg_cputime_s, (sql.elapsed_time_delta / 1000000) / decode(nvl(sql.executions_delta, 0), 0, 1, sql.executions_delta) avg_etime_s, sql.disk_reads_delta / decode(nvl(sql.executions_delta, 0), 0, 1, sql.executions_delta) avg_pio, sql.rows_processed_total / decode(nvl(sql.executions_delta, 0), 0, 1, sql.executions_delta) avg_row from dba_hist_sqlstat sql, dba_hist_snapshot s where sql.instance_number = (select instance_number from v$instance) and sql.dbid = (select dbid from v$database) and s.snap_id = sql.snap_id and sql_id in ('&sqlid') order by s.snap_id;

    SnapId PLAN_HASH_VALUE Date time            No. of exec        LIO/exec CPUTIM/exec  ETIME/exec    PIO/exec   ROWs/exec
--------- --------------- -------------------- ----------- --------------- ----------- ----------- ----------- -----------
     22929      1590966356 08/11/18_1500_1600             1     24267882.00      942.34     2218.04 ###########  1754123.00
     22931      1590966356 08/11/18_1700_1800             1     22899127.00      871.99     1997.07 ###########  2079141.00
     22937      1590966356 08/11/18_2300_0000             1     26613884.00     1019.25     4234.83 ###########  5311544.00
     22949      1590966356 08/12/18_1100_1200             1     24680480.00      978.86     2424.50 ###########  7152531.00
     22955      1590966356 08/12/18_1700_1800             1     25035846.00      995.97     2129.30 ###########  9363924.00
     22997      1564180558 08/14/18_1100_1200             1      1098647.00       98.23      324.97        9.00   929961.00

2.2根据SQL_ID获取执行计划的信息

select * from table(dbms_xplan.display_awr('&1'));

上述结果中，关注当前的执行计划值（plan_hash_value）,单次逻辑读（lio），单次物理读（pio），以及该语句是否已经被绑定执行计划（profile）

 

2.3根据SQL_ID获取内存中的执行计划的信息


select * from table(dbms_xplan.display_cursor('&1',null,'allstats last +cost'));


 


PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------------------------------------------
SQL_ID  cd7ftyrjgvasy, child number 0
-------------------------------------
MERGE /*+parallel (4)*/ INTO BS_PROCMAIN A USING ML_QW_PROCMAIN_03 B
ON (A.POLICYNO = B.POLICYNO   AND A.CompanyCode = B.CompanyCode ) WHEN
MATCHED THEN    UPDATE SET  A.PayTimes =
GREATEST(NVL(A.PayTimes,B.PayTimes),NVL(B.PayTimes,A.PayTimes)) WHEN
NOT MATCHED THEN      INSERT     (         CompanyCode,
PolicyNo,          PayTimes      )                    VALUES (
B.CompanyCode,          B.PolicyNo,
B.PayTimes    )

Plan hash value: 1564180558

------------------------------------------------------------------------------------
| Id  | Operation                        | Name              | E-Rows | Cost (%CPU)|
------------------------------------------------------------------------------------
|   0 | MERGE STATEMENT                  |                   |        |  3040 (100)|
|   1 |  MERGE                           | BS_PROCMAIN       |        |            |
|   2 |   PX COORDINATOR                 |                   |        |            |
|   3 |    PX SEND QC (RANDOM)           | :TQ10000          |   3793 |  3040   (1)|
|   4 |     VIEW                         |                   |        |            |
|   5 |      NESTED LOOPS OUTER          |                   |   3793 |  3040   (1)|
|   6 |       PX BLOCK ITERATOR          |                   |        |            |
|*  7 |        TABLE ACCESS FULL         | ML_QW_PROCMAIN_03 |   3643 |     2   (0)|
|   8 |       TABLE ACCESS BY INDEX ROWID| BS_PROCMAIN       |      1 |     1   (0)|
|*  9 |        INDEX UNIQUE SCAN         | PK_BSMAIN         |      1 |     1   (0)|
------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   7 - access(:Z>=:Z AND :Z<=:Z)
   9 - access("A"."COMPANYCODE"="B"."COMPANYCODE" AND
              "A"."POLICYNO"="B"."POLICYNO")
Note

-----
   - dynamic sampling used for this statement (level=6)
   - Degree of Parallelism is 4 because of hint
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

2.4根据SQL_ID获取内存中的执行计划的详细信息

select * from table(dbms_xplan.display_cursor('&1',null,'advanced'));

PLAN_TABLE_OUTPUT

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SQL_ID  cd7ftyrjgvasy, child number 0

-------------------------------------
MERGE /*+parallel (4)*/ INTO BS_PROCMAIN A USING ML_QW_PROCMAIN_03 B
ON (A.POLICYNO = B.POLICYNO   AND A.CompanyCode = B.CompanyCode ) WHEN
MATCHED THEN    UPDATE SET  A.PayTimes =
GREATEST(NVL(A.PayTimes,B.PayTimes),NVL(B.PayTimes,A.PayTimes)) WHEN
NOT MATCHED THEN      INSERT     (         CompanyCode,
PolicyNo,          PayTimes      )                    VALUES (
B.CompanyCode,          B.PolicyNo,
B.PayTimes    )
Plan hash value: 1564180558

 
-----------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                        | Name              | Rows  | Bytes | Cost (%CPU)| Time     |    TQ  |IN-OUT| PQ Distrib |
-----------------------------------------------------------------------------------------------------------------------------------
|   0 | MERGE STATEMENT                  |                   |       |       |  3040 (100)|          |        |      |            |
|   1 |  MERGE                           | BS_PROCMAIN       |       |       |            |          |        |      |            |
|   2 |   PX COORDINATOR                 |                   |       |       |            |          |        |      |            |
|   3 |    PX SEND QC (RANDOM)           | :TQ10000          |  3793 |  1292K|  3040   (1)| 00:00:37 |  Q1,00 | P->S | QC (RAND)  |
|   4 |     VIEW                         |                   |       |       |            |          |  Q1,00 | PCWP |            |
|   5 |      NESTED LOOPS OUTER          |                   |  3793 |  1292K|  3040   (1)| 00:00:37 |  Q1,00 | PCWP |            |
|   6 |       PX BLOCK ITERATOR          |                   |       |       |            |          |  Q1,00 | PCWC |            |
|*  7 |        TABLE ACCESS FULL         | ML_QW_PROCMAIN_03 |  3643 |   238K|     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|   8 |       TABLE ACCESS BY INDEX ROWID| BS_PROCMAIN       |     1 |   282 |     1   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|*  9 |        INDEX UNIQUE SCAN         | PK_BSMAIN         |     1 |       |     1   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-----------------------------------------------------------------------------------------------------------------------------------

 

Query Block Name / Object Alias (identified by operation id):

   1 - MRG$1
   5 - SEL$F5BB74E1
   7 - SEL$F5BB74E1 / B@SEL$1
   8 - SEL$F5BB74E1 / A@SEL$2
   9 - SEL$F5BB74E1 / A@SEL$2

 

Outline Data

-------------
 /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('11.2.0.4')
      DB_VERSION('11.2.0.4')
      OPT_PARAM('optimizer_dynamic_sampling' 6)
      ALL_ROWS
      SHARED(4)
      OUTLINE_LEAF(@"SEL$F5BB74E1")
      MERGE(@"SEL$2")
      OUTLINE_LEAF(@"MRG$1")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$2")
      FULL(@"MRG$1" "A"@"MRG$1")
      NO_ACCESS(@"MRG$1" "from$_subquery$_006"@"MRG$1")
      FULL(@"MRG$1" "B"@"MRG$1")
      LEADING(@"MRG$1" "A"@"MRG$1" "from$_subquery$_006"@"MRG$1" "B"@"MRG$1")
      USE_MERGE_CARTESIAN(@"MRG$1" "from$_subquery$_006"@"MRG$1")
      USE_MERGE_CARTESIAN(@"MRG$1" "B"@"MRG$1")
      FULL(@"SEL$F5BB74E1" "B"@"SEL$1")
      INDEX_RS_ASC(@"SEL$F5BB74E1" "A"@"SEL$2" ("BS_PROCMAIN"."COMPANYCODE" "BS_PROCMAIN"."POLICYNO"))
      LEADING(@"SEL$F5BB74E1" "B"@"SEL$1" "A"@"SEL$2")
      USE_NL(@"SEL$F5BB74E1" "A"@"SEL$2")
      PQ_DISTRIBUTE(@"SEL$F5BB74E1" "A"@"SEL$2" NONE BROADCAST)
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):

--------------------------------------------------
   7 - access(:Z>=:Z AND :Z<=:Z)
   9 - access("A"."COMPANYCODE"="B"."COMPANYCODE" AND "A"."POLICYNO"="B"."POLICYNO")




2.5根据SQL_ID查询当前的执行计划信息

 set lines 300 pages 300                                      
 col SQL_ID for a13
 col sql_profile for a15                                     
select a.sql_id ,a.plan_hash_value ,a.child_number ,a.sql_profile ,a.executions ,round(a.elapsed_time/1000000/a.executions,2) elapsed_time ,round(a.buffer_gets/a.executions,2) buffer_gets ,round(a.disk_reads/a.executions,2) disk_reads ,round(a.cpu_time/1000000/a.executions,2) cpu_time ,round(a.rows_processed/a.executions,2) rows_processed from v$sql a where a.sql_id ='&sqlid' order by plan_hash_value, child_number;                      

 

SQL_ID        PLAN_HASH_VALUE CHILD_NUMBER SQL_PROFILE     EXECUTIONS ELAPSED_TIME BUFFER_GETS DISK_READS   CPU_TIME ROWS_PROCESSED

------------- --------------- ------------ --------------- ---------- ------------ ----------- ---------- ---------- --------------
3w9qnvm3ssxq4      2387518517            0 coe_3w9qnvm3ssx          1      5661.04    54501447   54259832    1070.45          10618
                                           q4_2387518517

 

注：SQL_PROFILE是指已绑定的执行计划sql_id的文件；.

 

2.6查询执行计划绑定的详细情况:

select name,sql_text,LAST_MODIFIED from dba_sql_profiles where NAME like 'coe_3w9qnvm3ssxq4%';
NAME                           SQL_TEXT                                                     LAST_MODIFIED
------------------------------ ------------------------------------------------------------ ------------------------------
coe_3w9qnvm3ssxq4_2387518517                                                                2018-08-12 19:33:09.000000
                               DELETE /*+parallel(a,4)*/FROM RYX_TBL_INSURANT_T A WHERE EX
                               ISTS (SELECT 1 FROM RYX_TBL_INSURANT_T_I
                               NCR B WHERE A.TBDH = B.TBDH AND A.BBXRBH
                                = B.BBXRBH AND A.CPDM = B.CPDM AND A.BZ
                               DM = B.BZDM AND A.BBRPC = B.BBRPC)

 

3.根据SQL_ID获取SQL语句中表的统计信息情况及相关索引、高水位情况
3.1查看表的索引情况

 col TABLE_OWNER for a15
 col TABLE_NAME for a25
 col INDEX_NAME for a30
 col COLUMN_NAME for a25
 select table_owner,table_name,index_name,column_name,column_position from dba_ind_columns where table_name=upper('&1') order by 3,5;


TABLE_OWNER     TABLE_NAME                INDEX_NAME                     COLUMN_NAME               COLUMN_POSITION
--------------- ------------------------- ------------------------------ ------------------------- ---------------
CXBDDJ          BS_PROCMAIN               PK_BSMAIN                      COMPANYCODE                             1
CXBDDJ          BS_PROCMAIN               PK_BSMAIN                      POLICYNO                                2

3.2查看表的相关字段的统计信息情况

 col OWNER for a12
 col column_name for a25
 col table_name for a25
 col HISTOGRAM for a15
 col stale_stats for a11
select a.owner,a.table_name,a.column_name,b.num_rows,a.num_distinct,a.num_nulls,a.last_analyzed,a.histogram from dba_tab_col_statistics a ,dba_tables b where a.owner=b.owner and a.table_name=b.table_name and a.table_name=upper('&table_name') and column_name in ('&column_name');

 

OWNER        TABLE_NAME                COLUMN_NAME                 NUM_ROWS NUM_DISTINCT  NUM_NULLS LAST_ANALYZED       HISTOGRAM
------------ ------------------------- ------------------------- ---------- ------------ ---------- ------------------- ---------------
CXBDDJ       BS_PROCMAIN               COMPANYCODE                189483800           42          0 2018-08-12 00:20:53 FREQUENCY
CXBDDJ       BS_PROCMAIN               POLICYNO                   189483800    185712640          0 2018-08-12 00:20:53 NONE

 

注：根据字段的NUM_ROWS、NUM_DISTINCT的值，查看字段的选择性情况，根据表的索引情况及执行计划的情况，判断索引是否合适，判断执行计划走的是否合适，是否有更合理的方式；

3.3查看表的统计信息情况失效情况

select owner,table_name,partition_name,object_type,stale_stats,last_analyzed from dba_tab_statistics where table_name=upper('&table_name');

OWNER        TABLE_NAME                PARTITION_NAME                 OBJECT_TYPE          STALE_STATS LAST_ANALYZED
------------ ------------------------- ------------------------------ -------------------- ----------- -------------------
CXBDDJ       BS_PROCMAIN                                              TABLE                YES         2018-08-12 01:06:17

 

注：STALE_STATS字段的值为YES，表示统计信息已失效；

 

3.4查看表的真实数据量

select /*+ parallel(8)*/ count(*) from &TABLE_NAME;

  COUNT(*)
----------
 190138247

注：查看真实数据与统计信息数据差距，判断统计信息失效情况对执行计划的影响；

3.5查看表的索引的大小及blevel的情况

col owner for a15
col TABLE_OWNER for a15
col index_name for a25
select s.owner,i.table_owner,i.table_name,index_name,blevel,round(s.bytes/1024/1024/1024,2) bytes_gb from dba_indexes i,dba_segments s where i.index_name=s.segment_name and i.table_name = upper('&table_name') order by 3 desc,4 desc;

 

OWNER           TABLE_OWNER     TABLE_NAME                INDEX_NAME                    BLEVEL   BYTES_GB
--------------- --------------- ------------------------- ------------------------- ---------- ----------
CXBDDJ          CXBDDJ          BS_PROCMAIN               PK_BSMAIN                          3      10.52

注：索引层数过多会导致该索引效率低下，使用该索引进行查询的语句会消耗更多的io读写,将层数过多（BLEVEL >3）的索引进行重建;

 

3.6查看表的索引的degree的情况

select owner,table_name,index_name,degree from dba_indexes where table_name = upper('&table_name');
OWNER           TABLE_NAME                INDEX_NAME                DEGREE
--------------- ------------------------- ------------------------- ----------------------------------------
CXBDDJ          BS_PROCMAIN               PK_BSMAIN                 1

注：当访问并行索引时，DEGREE >1时，CBO可能会考虑并行执行，这可能会引发一些问题，如在服务器资源紧张的时候用并行引起更加严重的争用，若DEGREE >1时，建议修并行度;

3.7查看表的索引的碎片情况

select idx.owner owner, idx.table_name table_name, idx.index_name index_name, idx.blocks idx_blocks, tbl.blocks tbl_blocks, trunc(idx.blocks / tbl.blocks * 100) / 100 pct from (select i.owner owner, i.index_name index_name, sum(s1.blocks) blocks, i.table_owner table_owner, i.table_name table_name from dba_segments s1, dba_indexes i where s1.owner = i.owner and s1.segment_name = i.index_name and s1.bytes / 1024 / 1024 / 1024 > 2 and i.owner not in ('SYS', 'OUTLN', 'SYSTEM', 'MGMT_VIEW', 'SYSMAN', 'DBSNMP', 'WMSYS', 'XDB', 'DIP', 'GOLDENGATE', 'CTXSYS') group by i.owner, i.index_name, i.table_owner, i.table_name) idx, (select t.owner owner, t.table_name table_name, sum(s2.blocks) blocks from dba_segments s2, dba_tables t where s2.owner = t.owner and s2.segment_name = t.table_name and t.owner not in ('SYS', 'OUTLN', 'SYSTEM', 'MGMT_VIEW', 'SYSMAN', 'DBSNMP', 'WMSYS', 'XDB', 'DIP', 'GOLDENGATE', 'CTXSYS') group by t.owner, t.table_name) tbl where idx.table_owner = tbl.owner and idx.table_name = tbl.table_name and tbl.table_name = '&table_name' order by 4;

 

OWNER           TABLE_NAME           INDEX_NAME                     IDX_BLOCKS TBL_BLOCKS        PCT
--------------- -------------------- ------------------------------ ---------- ---------- ----------
CXBDDJ          BS_PROCMAIN          PK_BSMAIN                         1378432    7714048        .17

 

注：索引碎片较大（PCT>1.0且IDX_BLOCKS较多），DML对其操作比较慢，当查询表时查询的块比较多，导致查询变慢；建议重建索引；

 

3.8查看表的高水位情况

set pagesize 1000
col segment_owner for a15
col segment_name for a30
col segment_type for a15
col tablespace_name for a15
col recommendations for a50
set linesize 220
select segment_owner, segment_name, segment_type, tablespace_name, round(allocated_space/1024/1024,2) alloc_mb, round(used_space/1024/1024,2 ) used_mb, round( reclaimable_space/1024/1024,2) reclaim_mb, round(reclaimable_space/allocated_space*100,2) pctsave from table(dbms_space.asa_recommendations()) where segment_type='table' and segment_name='&table_name' order by reclaim_mb desc;

 

SEGMENT_OWNER   SEGMENT_NAME                   SEGMENT_TYPE    TABLESPACE_NAME   ALLOC_MB    USED_MB RECLAIM_MB    PCTSAVE
--------------- ------------------------------ --------------- --------------- ---------- ---------- ---------- ----------
CXBDDJ          BS_PROCMAIN                    TABLE           CXBDDJ_DATA          60522   60130.82     391.18        .65

 

注：表的高水位较高（PCTSAVE>50且RECLAIM_MB较多），对于表的频繁DML操作会引起表中产生大量碎片，使表的水位线过高。碎片在浪费数据库空间的同时，也会使相关查询语句的消耗更多。对表进行空间回收，减少表的高水位和碎片情况；
4.根据SQL语句的执行计划信息进行SQL的优化分析
SQL_ID  cd7ftyrjgvasy, child number 0

-------------------------------------

Plan hash value: 1564180558

------------------------------------------------------------------------------------
| Id  | Operation                        | Name              | E-Rows | Cost (%CPU)|
------------------------------------------------------------------------------------
|   0 | MERGE STATEMENT                  |                   |        |  3040 (100)|
|   1 |  MERGE                           | BS_PROCMAIN       |        |            |
|   2 |   PX COORDINATOR                 |                   |        |            |
|   3 |    PX SEND QC (RANDOM)           | :TQ10000          |   3793 |  3040   (1)|
|   4 |     VIEW                         |                   |        |            |
|   5 |      NESTED LOOPS OUTER          |                   |   3793 |  3040   (1)|
|   6 |       PX BLOCK ITERATOR          |                   |        |            |
|*  7 |        TABLE ACCESS FULL         | ML_QW_PROCMAIN_03 |   3643 |     2   (0)|
|   8 |       TABLE ACCESS BY INDEX ROWID| BS_PROCMAIN       |      1 |     1   (0)|
|*  9 |        INDEX UNIQUE SCAN         | PK_BSMAIN         |      1 |     1   (0)|

------------------------------------------------------------------------------------

Predicate Information (identified by operation id):

---------------------------------------------------

   7 - access(:Z>=:Z AND :Z<=:Z)

   9 - access("A"."COMPANYCODE"="B"."COMPANYCODE" AND

              "A"."POLICYNO"="B"."POLICYNO")

 

注：根据执行计划中访问表的方法、访问索引的方法、表连接的类型、表连接的方法、反连接、半连接、星型连接等结合SQL语句及数据情况，查看是否合适，若不合适，可以进行SQL语句改写或者加hint（use_hash、use_nl、index等）进行固定执行计划中的连接方法等；

 

4.1. 查看执行计划中谓词过滤字段是否有索引，执行计划是否走索引扫描
4.1.1.根据执行计划中访问表的方法、访问索引的方法、表连接的类型、表连接的方法、反连接、半连接、星型连接等结合SQL语句及数据情况，查看是否合适；
4.1.2.若不合适，可以根据具体情况进行SQL语句改写（exists 、with as 改写等）；
4.1.3.加hint（ index、 use_hash、use_nl、no_merge等）进行固定执行计划中的连接方法等；
4.1.4.走索引扫描，索引是否合适,根据索引方式、索引情况进行判断，若不合适，考虑建立合适的索引；
4.1.5.走全表扫描，谓词过滤字段是否有索引：
Ø 谓词过滤字段有索引，未走索引扫描，查看过滤字段的选择性的好坏；
Ø 谓词过滤字段有索引，未走索引扫描，查看过滤字段的统计信息失效情况；
Ø 谓词过滤字段有索引，未走索引扫描，查看过滤字段的是否存在隐式转换；

Ø 谓词过滤字段有索引，未走索引扫描，查看字段的绑定变量类型与字段的类型是否一致；

Ø 谓词过滤字段没有索引，查看过滤字段的选择性，根据情况，考虑创建合适的索引；

5.根据SQL语句的执行计划信息来固定执行计划
5.1. 绑定当前已有的执行计划
5.1.1. 检查绑定脚本是否存在
绑定脚本位置：/home/oracle/coe_xfr_sql_profile.sql，若没有该脚本，在svn目录（SJK\优化小组\脚本\coe_xfr_sql_profile.sql

）；

5.1.2. 执行绑定脚本进行生成绑定文件，然后进行绑定
SQL> @coe_xfr_sql_profile.sql;

输入需要绑定的sql_id，然后输入对应的plan_hash_value,然后生成对应的sql_profile脚本，执行生产的脚本进行绑定即可;

例：SQL> @ coe_xfr_sql_profile_6dfpa1uh9xsv3_3160514392.sql;

 

5.2. 伪造执行计划，再进行绑定
5.2.1.通过hint，将语句的执行计划梳理成想要的执行计划
通过语句select * from table(dbms_xplan.display_cursor('&1',null,'advanced')); 获取想要的Outline Data（详情请见 2.4）；

 

 

5.2.2. 执行绑定脚本进行生成绑定文件，然后把Outline Data部分替换成加hint生成想要的执行计划Outline Data；
这部分outline，就是想要的执行计划的outline，替换原来脚本中的outline，注意前后加上q'[...]',等符号(force_match => FALSE，改为force_match => TRUE,基于SQL中常量的变化同样有效)，然后执行前面生成的脚本；

 

 

 

5.3. 查询执行计划绑定的详细情况
 

col SQL_TEXT for a60
col LAST_MODIFIED for a30
select name,sql_text,LAST_MODIFIED from dba_sql_profiles where NAME like 'coe_3w9qnvm3ssxq4%';

NAME                           SQL_TEXT                                                     LAST_MODIFIED
------------------------------ ------------------------------------------------------------ ------------------------------
coe_3w9qnvm3ssxq4_2387518517                                                                2018-08-12 19:33:09.000000
                               DELETE /*+parallel(a,4)*/FROM RYX_TBL_INSURANT_T A WHERE EX
                               ISTS (SELECT 1 FROM RYX_TBL_INSURANT_T_I
                               NCR B WHERE A.TBDH = B.TBDH AND A.BBXRBH
                                = B.BBXRBH AND A.CPDM = B.CPDM AND A.BZ
                               DM = B.BZDM AND A.BBRPC = B.BBRPC)

 

5.4. 查询语句的当前执行计划信息
 

SQL_ID        PLAN_HASH_VALUE CHILD_NUMBER SQL_PROFILE     EXECUTIONS ELAPSED_TIME BUFFER_GETS DISK_READS   CPU_TIME ROWS_PROCESSED

------------- --------------- ------------ --------------- ---------- ------------ ----------- ---------- ---------- --------------

3w9qnvm3ssxq4      2387518517            0 coe_3w9qnvm3ssx          1      5661.04    54501447   54259832    1070.45          10618

                                           q4_2387518517

 

注：SQL_PROFILE是指已绑定的执行计划sql_id的文件（详情见2.5）

；

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

第二部分：在预生产上对SQL语句进行测试分析

 

1. 在网站https://sso.hq.cpic.com/login点击CIMS菜单查询对应数据库IP地址的预生产库相关信息；

例：查询10.190.42.35系统：

 

在网站https://sso.hq.cpic.com/login

2. 联系陈炜强老师询问数据库IP地址对应的预生产相关信息或修复预生产库上的相关数据不同步问题；

陈炜强老师：（chenweiqiang-004，集团\信息技术中心\基础设施运行部\运维体系管理功能区\非生产数据库和中间件管理）