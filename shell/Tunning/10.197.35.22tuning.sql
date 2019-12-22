10.197.35.22tuning.sql

SQL> set linesize 200 pagesize 900
SQL>  select * from table(dbms_xplan.display_cursor('&1',null,'ALL')); 
Enter value for 1: ffgft36dxzgb8
old   1:  select * from table(dbms_xplan.display_cursor('&1',null,'ALL'))
new   1:  select * from table(dbms_xplan.display_cursor('ffgft36dxzgb8',null,'ALL'))

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID  ffgft36dxzgb8, child number 0
-------------------------------------
select  *   from (select /*+ parallel(a,8) */          vehicle_id,
vehicle_license           from t_market_sales a          where a.m_type
= '9071'            and a.create_person = 'manager'            and
a.business_type <> '13'            and a.sales_status in ('11', '12',
'13', '14')) a,        (select /*+ parallel(t,8) */
vehicle_id, vehicle_license           from t_market_sales t
where t.m_type = '9071'            and t.create_person = 'I07'
  and t.business_type <> '13'            and t.sales_status in ('11',
'12', '13', '14')            and t.create_date >= to_date('20190601',
'yyyymmdd')) b  where a.vehicle_id = b.vehicle_id    and
a.vehicle_license = b.vehicle_license

Plan hash value: 3298115222

---------------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name                | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |    TQ  |IN-OUT| PQ Distrib |
---------------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |                     |       |       |   396K(100)|          |       |       |        |      |            |
|   1 |  PX COORDINATOR                      |                     |       |       |            |          |       |       |        |      |            |
|   2 |   PX SEND QC (RANDOM)                | :TQ10000            |  2884 |   287K|   396K  (1)| 01:19:22 |       |       |  Q1,00 | P->S | QC (RAND)  |
|   3 |    NESTED LOOPS                      |                     |  2884 |   287K|   396K  (1)| 01:19:22 |       |       |  Q1,00 | PCWP |            |
|   4 |     NESTED LOOPS                     |                     |  2884 |   287K|   396K  (1)| 01:19:22 |       |       |  Q1,00 | PCWP |            |
|   5 |      PX BLOCK ITERATOR               |                     |  2884 |   132K|   363K  (1)| 01:12:38 |     1 |    41 |  Q1,00 | PCWC |            |
|*  6 |       TABLE ACCESS FULL              | T_MARKET_SALES      |  2884 |   132K|   363K  (1)| 01:12:38 |     1 |    41 |  Q1,00 | PCWP |            |
|   7 |      PARTITION LIST ALL              |                     |     1 |       |    82   (0)| 00:00:01 |     1 |    41 |  Q1,00 | PCWP |            |
|*  8 |       INDEX RANGE SCAN               | IDX_MARKET_SALES_08 |     1 |       |    82   (0)| 00:00:01 |     1 |    41 |  Q1,00 | PCWP |            |
|*  9 |     TABLE ACCESS BY LOCAL INDEX ROWID| T_MARKET_SALES      |     1 |    55 |    84   (0)| 00:00:02 |     1 |     1 |  Q1,00 | PCWP |            |
---------------------------------------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$5428C7F1
   6 - SEL$5428C7F1 / A@SEL$2
   8 - SEL$5428C7F1 / T@SEL$3
   9 - SEL$5428C7F1 / T@SEL$3

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access(:Z>=:Z AND :Z<=:Z)
       filter(("A"."CREATE_PERSON"='manager' AND "A"."M_TYPE"='9071' AND INTERNAL_FUNCTION("A"."SALES_STATUS") AND "A"."BUSINESS_TYPE"<>'13'))
   8 - access("VEHICLE_LICENSE"="VEHICLE_LICENSE")
   9 - filter(("T"."CREATE_PERSON"='I07' AND "T"."CREATE_DATE">=TO_DATE(' 2019-06-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
              "T"."M_TYPE"='9071' AND INTERNAL_FUNCTION("T"."SALES_STATUS") AND "T"."BUSINESS_TYPE"<>'13' AND "VEHICLE_ID"="VEHICLE_ID"))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50], "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50]
   2 - (#keys=0) "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50], "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50]
   3 - "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50], "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50]
   4 - "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50], "T".ROWID[ROWID,10], "VEHICLE_LICENSE"[VARCHAR2,50]
   5 - "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50]
   6 - "VEHICLE_ID"[VARCHAR2,20], "VEHICLE_LICENSE"[VARCHAR2,50]
   7 - "T".ROWID[ROWID,10], "VEHICLE_LICENSE"[VARCHAR2,50]
   8 - "T".ROWID[ROWID,10], "VEHICLE_LICENSE"[VARCHAR2,50]
   9 - "VEHICLE_ID"[VARCHAR2,20]

Note
-----
   - dynamic sampling used for this statement (level=7)


65 rows selected.




SQL> select dbms_sqltune.REPORT_SQL_MONITOR(SQL_ID=>'&sqlid',TYPE=>'TEXT') as comm from dual;
Enter value for sqlid: 36gggg4u8hffm
old   1: select dbms_sqltune.REPORT_SQL_MONITOR(SQL_ID=>'&sqlid',TYPE=>'TEXT') as comm from dual
new   1: select dbms_sqltune.REPORT_SQL_MONITOR(SQL_ID=>'36gggg4u8hffm',TYPE=>'TEXT') as comm from dual
SQL Monitoring Report

SQL Text
------------------------------
select count(1) from t_market_sales where (vehicle_id, vehicle_license) in ( select b.vehicle_id, b.vehicle_license from (select /*+ parallel(a,8) */ vehicle_id, vehicle_license from t_market_sales a where a.m_type = '9071' and a.create_person = 'manager' and a.business_type <> '13' and a.sales_stat
us in ('11', '12', '13', '14')) a, (select /*+ parallel(t,8) */ vehicle_id, vehicle_license from t_market_sales t where t.m_type = '9071' and t.create_person = 'I07' and t.business_type <> '13' and
t.sales_status in ('11', '12', '13', '14') and t.create_date >= to_date('20190601', 'yyyymmdd')) b where a.vehicle_id = b.vehicle_id and a.vehicle_license = b.vehicle_license)

Global Information
------------------------------
 Status              :  EXECUTING
 Instance ID         :  1
 Session             :  NCXDXREAD (247:51695)
 SQL ID              :  36gggg4u8hffm
 SQL Execution ID    :  16777216
 Execution Started   :  07/25/2019 19:37:45
 First Refresh Time  :  07/25/2019 19:37:45
 Last Refresh Time   :  07/25/2019 19:39:13
 Duration            :  89s
 Module/Action       :  PL/SQL Developer/SQL Window - New
 Service             :  cxdx
 Program             :  plsqldev.exe
 DOP Downgrade       :  75%

Global Stats
=======================================================================
| Elapsed |   Cpu   |    IO    | Application | Buffer | Read  | Read  |
| Time(s) | Time(s) | Waits(s) |  Waits(s)   |  Gets  | Reqs  | Bytes |
=======================================================================
|     179 |      46 |      133 |        0.19 |    28M | 48511 |  47GB |
=======================================================================

Parallel Execution Details (DOP=2 , Servers Requested=16 , Servers Allocated=4)
=================================================================================================================================================
|      Name      | Type  | Server# | Elapsed |   Cpu   |    IO    | Application | Buffer | Read  | Read  |             Wait Events              |
|                |       |         | Time(s) | Time(s) | Waits(s) |  Waits(s)   |  Gets  | Reqs  | Bytes |              (sample #)              |
=================================================================================================================================================
| PX Coordinator | QC    |         |    0.21 |    0.02 |          |        0.19 |    629 |       |     . | enq: KO - fast object checkpoint (1) |
| p000           | Set 1 |       1 |         |         |          |             |        |       |     . |                                      |
| p001           | Set 1 |       2 |         |         |          |             |        |       |     . |                                      |
| p002           | Set 2 |       1 |      89 |      25 |       65 |             |    16M | 24474 |  24GB | direct path read (56)                |
| p003           | Set 2 |       2 |      89 |      21 |       68 |             |    12M | 24037 |  23GB | direct path read (73)                |
=================================================================================================================================================

SQL Plan Monitoring Details (Plan Hash Value=224088295)
===================================================================================================================================================================================================================
| Id    |                    Operation                     |        Name         |  Rows   | Cost |   Time    | Start  | Execs |   Rows   | Read  | Read  | Mem | Activity |          Activity Detail             |
|       |                                                  |                     | (Estim) |      | Active(s) | Active |       | (Actual) | Reqs  | Bytes |     |   (%)    |    (# samples)               |
===================================================================================================================================================================================================================
|     0 | SELECT STATEMENT                                 |                     |         |      |           |        |     1 |          |       |       |     |          |     |
|     1 |   SORT AGGREGATE                                 |                     |       1 |      |           |        |     1 |          |       |       |     |          |     |
|     2 |    PX COORDINATOR                                |                     |         |      |         1 |     +0 |     3 |        0 |       |       |     |     0.56 | enq: KO - fast object checkpoint (1) |
|     3 |     PX SEND QC (RANDOM)                          | :TQ10001            |       1 |      |           |        |       |          |       |       |     |          |     |
|     4 |      SORT AGGREGATE                              |                     |       1 |      |           |        |       |          |       |       |     |          |     |
|     5 |       VIEW                                       | VM_NWVW_2           |    2884 | 430K |           |        |       |          |       |       |     |          |     |
|     6 |        HASH UNIQUE                               |                     |    2884 | 430K |           |        |       |          |       |       |     |          |     |
|     7 |         PX RECEIVE                               |                     |    2884 | 430K |           |        |       |          |       |       |     |          |     |
|     8 |          PX SEND HASH                            | :TQ10000            |    2884 | 430K |           |        |     2 |          |       |       |     |          |     |
|  -> 9 |           HASH UNIQUE                            |                     |    2884 | 430K |        79 |    +12 |     2 |        0 |       |       |  3M |          |     |
| -> 10 |            NESTED LOOPS                          |                     |    2884 | 430K |        79 |    +12 |     2 |     1485 |       |       |     |          |     |
| -> 11 |             NESTED LOOPS                         |                     |    2884 | 430K |        79 |    +12 |     2 |     2045 |       |       |     |          |     |
| -> 12 |              NESTED LOOPS                        |                     |    2884 | 397K |        89 |     +2 |     2 |      699 |       |       |     |          |     |
| -> 13 |               PX BLOCK ITERATOR                  |                     |    2884 | 363K |        89 |     +2 |     2 |     171K |       |       |     |          |     |
| -> 14 |                TABLE ACCESS FULL                 | T_MARKET_SALES      |    2884 | 363K |        90 |     +1 |  1145 |     171K | 48511 |  47GB |     |    87.71 | Cpu (28)                             |
|       |                                                  |                     |         |      |           |        |       |          |       |       |     |          | direct path read (129)               |
| -> 15 |               PARTITION LIST ALL                 |                     |       1 |   84 |        79 |    +12 |  171K |      699 |       |       |     |     0.56 | Cpu (1)                              |
| -> 16 |                TABLE ACCESS BY LOCAL INDEX ROWID | T_MARKET_SALES      |       1 |   84 |        89 |     +2 |    7M |      699 |       |       |     |     1.12 | Cpu (2)                              |
| -> 17 |                 INDEX RANGE SCAN                 | IDX_MARKET_SALES_08 |       1 |   82 |        89 |     +2 |    7M |     344K |       |       |     |    10.06 | Cpu (18)                             |
| -> 18 |              PARTITION LIST ALL                  |                     |       1 |   82 |        79 |    +12 |   699 |     2045 |       |       |     |          |     |
| -> 19 |               INDEX RANGE SCAN                   | IDX_MARKET_SALES_08 |       1 |   82 |        79 |    +12 | 28659 |     2045 |       |       |     |          |     |
| -> 20 |             TABLE ACCESS BY LOCAL INDEX ROWID    | T_MARKET_SALES      |       1 |   82 |        79 |    +12 |  2045 |     1485 |       |       |     |          |     |
===================================================================================================================================================================================================================


SQL> set linesize 300                                              
SQL> set pagesize 900                                              
SQL> col sql_profile for a30                                       
SQL>  col LAST_LOAD_TIME for a20
SQL> select a.SQL_ID                                               
  2  ,a.PLAN_HASH_VALUE                                            
  3  ,a.CHILD_NUMBER                                               
  4  ,a.sql_profile                                                
  5  ,a.EXECUTIONS                                                 
  6  ,round(a.ELAPSED_TIME/1000000/a.EXECUTIONS,2) ELAPSED_TIME    
  7  ,round(a.BUFFER_GETS/a.EXECUTIONS,2) BUFFER_GETS              
  8  ,round(a.DISK_READS/a.EXECUTIONS,2) DISK_READS                
  9  ,round(a.CPU_TIME/1000000/a.EXECUTIONS,2) CPU_TIME            
 10  ,round(a.ROWS_PROCESSED/a.EXECUTIONS,2) ROWS_PROCESSED        
 11   , LAST_LOAD_TIME 
 12   from v$sql a where a.SQL_ID ='&sqlid'                         
 13  order by PLAN_HASH_VALUE, CHILD_NUMBER;                       
Enter value for sqlid: 36gggg4u8hffm
old  12:  from v$sql a where a.SQL_ID ='&sqlid'
new  12:  from v$sql a where a.SQL_ID ='36gggg4u8hffm'

                                           SQL
SQL_ID        PLAN_HASH_VALUE CHILD_NUMBER Profile                        EXECUTIONS ELAPSED_TIME BUFFER_GETS DISK_READS   CPU_TIME ROWS_PROCESSED LAST_LOAD_TIME
------------- --------------- ------------ ------------------------------ ---------- ------------ ----------- ---------- ---------- -------------- --------------------
36gggg4u8hffm       224088295            0                                         1       277.34    45673422    9579415      75.09              1 2019-07-25/19:37:43




[jtdba@CXDHXSDB3522 ~]$ lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                20
On-line CPU(s) list:   0-19
Thread(s) per core:    1
Core(s) per socket:    5
Socket(s):             4
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 63
Stepping:              4
CPU MHz:               2194.712
BogoMIPS:              4389.42
Hypervisor vendor:     VMware
Virtualization type:   full
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              40960K
NUMA node0 CPU(s):     0-19
[jtdba@CXDHXSDB3522 ~]$ free -m
             total       used       free     shared    buffers     cached
Mem:         80587      53796      26791          0       3124       3587
-/+ buffers/cache:      47084      33503
Swap:        57343         13      57330
[jtdba@CXDHXSDB3522 ~]$ dstat -talm
----system---- ----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system-- ---load-avg--- ------memory-usage-----
  date/time   |usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw | 1m   5m  15m | used  buff  cach  free
25-07 19:42:28|  4   1  87   9   0   0|  80M   14M|   0     0 | 373k  174k|2570  8810 |3.18 3.06 3.06|46.0G 3125M 3590M 26.2G
25-07 19:42:29|  2   0  86  12   0   0| 357M  699k|  41k  187k|   0     0 |4918  5838 |3.08 3.04 3.06|46.0G 3125M 3590M 26.2G
25-07 19:42:30|  1   0  85  13   0   0| 463M  881k|  62k  244k|   0     0 |5362  5893 |3.08 3.04 3.06|46.0G 3125M 3590M 26.2G
25-07 19:42:31|  2   1  83  14   0   0| 388M 4372k| 179k  722k|   0     0 |6484  7290 |3.08 3.04 3.06|46.0G 3125M 3589M 26.2G
25-07 19:42:32|  3   1  82  14   0   0| 513M 2599k| 200k  904k|   0     0 |8838  9932 |3.08 3.04 3.06|46.0G 3125M 3588M 26.2G
25-07 19:42:33|  2   1  87  10   0   0| 581M 1137k|  59k  249k|   0     0 |6083  7421 |3.08 3.04 3.06|46.0G 3125M 3589M 26.2G
25-07 19:42:34|  2   1  86  11   0   0| 648M 4783k|  87k  469k|   0     0 |6716  8079 |3.16 3.05 3.06|46.0G 3125M 3590M 26.2G
25-07 19:42:35|  1   1  85  13   0   0| 466M 2628k|  61k  237k|   0     0 |6022  7410 |3.16 3.05 3.06|46.0G 3125M 3589M 26.2G
25-07 19:42:36|  2   1  84  13   0   0| 477M 1267k|  84k  376k|   0     0 |5807  5989 |3.16 3.05 3.06|46.0G 3125M 3589M 26.2G
25-07 19:42:37|  2   0  87  10   0   0| 534M 2051k|  31k  116k|   0     0 |5885  5941 |3.16 3.05 3.06|46.0G 3125M 3589M 26.2G
25-07 19:42:38|  2   1  86  12   0   0| 511M 4039k| 110k  532k|   0     0 |6117  6857 |3.16 3.05 3.06|46.0G 3125M 3589M 26.2G
25-07 19:42:39|  3   1  85  11   0   0| 518M 1326k|  55k  251k|   0     0 |6411  7399 |2.98 3.02 3.05|46.0G 3125M 3589M 26.2G
25-07 19:42:40|  2   1  86  12   0   0| 496M 3933k|  70k  311k|   0     0 |6661  6756 |2.98 3.02 3.05|46.0G 3125M 3590M 26.2G
25-07 19:42:41|  3   1  79  18   0   0| 518M 3249k| 266k 1116k|   0     0 |8669  9440 |2.98 3.02 3.05|46.0G 3125M 3589M 26.2G
25-07 19:42:42|  3   1  81  15   0   0| 478M 2331k| 187k  905k|   0     0 |7110  7623 |2.98 3.02 3.05|46.0G 3125M 3588M 26.2G
25-07 19:42:43|  2   1  82  16   0   0| 486M 5226k|  83k  435k|   0     0 |6119  6632 |2.98 3.02 3.05|46.0G 3125M 3590M 26.2G^C







---------------------------------------------------------------------------------------------


































