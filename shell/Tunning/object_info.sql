object_info.sql
===============================================
set linesize 300
col owner for a15
col table_name for a30
col tablespace_name for a30
col partitioned for a10
select owner,table_name,num_rows,blocks,TEMPORARY,tablespace_name,partitioned,last_analyzed  from dba_tables where table_name=nvl('&table_name',table_name);
Enter value for table_name: T_TASK_MAIN
old   1:  select owner,table_name,num_rows,blocks,TEMPORARY,tablespace_name,partitioned,last_analyzed  from dba_tables where table_name=nvl('&table_name',table_name)
new   1:  select owner,table_name,num_rows,blocks,TEMPORARY,tablespace_name,partitioned,last_analyzed  from dba_tables where table_name=nvl('T_TASK_MAIN',table_name)

OWNER           TABLE_NAME                       NUM_ROWS     BLOCKS T TABLESPACE_NAME                PARTITIONE LAST_ANALYZED
--------------- ------------------------------ ---------- ---------- - ------------------------------ ---------- -------------------
NCXDX           T_TASK_MAIN                     135844247    1883732 N CXDX_BIZ_CAR_DATA              NO         2019-07-06 01:27:05


col table_name format a25
col index_name format a30
col column_name format a20
col tablespace_name format a15
col index_type format a17
col column_expression format a20
col column_position heading 'COLUMN|POSITION'
select a.table_owner,a.table_name,a.index_name,a.column_name,b.tablespace_name,b.index_type,c.column_expression
from dba_ind_columns a,dba_indexes b,dba_ind_expressions c
where a.index_name = b.index_name
and a.index_name=c.index_name(+)
and a.table_name=c.table_name(+)
and a.column_position=c.column_position(+)
and a.table_name = upper('&table_name')
order by a.index_name,a.column_position;

Enter value for table_name: T_TASK_MAIN
old   7: and a.table_name = upper('&table_name')
new   7: and a.table_name = upper('T_TASK_MAIN')

TABLE_OWNER                    TABLE_NAME                INDEX_NAME                     COLUMN_NAME          TABLESPACE_NAME INDEX_TYPE        COLUMN_EXPRESSION
------------------------------ ------------------------- ------------------------------ -------------------- --------------- ----------------- --------------------
NCXDX                          T_TASK_MAIN               PK_T_TASK_MAIN                 TASK_RECORD_ID       CXDX_BIZ_CAR_ID NORMAL




col owner for a12
col name for a25
col part_type for a30
set lines 200 pages 200
select a.owner,       a.name,       c.num_rows,       'by-'||a.column_name||'-down-'||decode(b.partitioning_type,'HASH','hash','RANGE','range','LIST','list')||'-partition' part_type,       b.partition_count,       b.subpartitioning_type,       b.subpartitioning_key_count   
from dba_part_key_columns a, dba_part_tables b ,dba_tables c 
where a.owner not in ('SYS','SYSTEM')   
and object_type = 'TABLE'   
and a.owner = b.owner   
and a.name = b.table_name   
and (name not like 'CHKPREACCT%' 
and name not like 'CLMPREACCT%'   
and name not like 'BIN$%')   
and c.owner=a.owner   
and c.table_name=a.name   
and c.table_name=nvl('&table_name',c.table_name) 
order by subpartitioning_type, partitioning_type, a.column_name,name;


set linesize 300
col owner for a20
col table_name for a25
col column_name for a30
col data_type for a15
select owner,table_name,column_name,data_type,num_distinct,last_analyzed  
from dba_tab_columns where table_name=nvl('&table_name',table_name) order by owner,table_name,column_name;
Enter value for table_name: T_TASK_MAIN
old   1: select owner,table_name,column_name,data_type,num_distinct,last_analyzed  from dba_tab_columns where table_name=nvl('&table_name',table_name) order by owner,table_name,column_name
new   1: select owner,table_name,column_name,data_type,num_distinct,last_analyzed  from dba_tab_columns where table_name=nvl('T_TASK_MAIN',table_name) order by owner,table_name,column_name

OWNER                TABLE_NAME                COLUMN_NAME                    DATA_TYPE       NUM_DISTINCT LAST_ANALYZED
-------------------- ------------------------- ------------------------------ --------------- ------------ -------------------
NCXDX                T_TASK_MAIN               CONTACT_ID                     VARCHAR2           134676480 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               CONTACT_TYPE                   VARCHAR2                   2 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               CREATE_DATE                    DATE                15916032 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               CREATE_PERSON                  VARCHAR2               18856 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               MIGRATION_MARK                 VARCHAR2                   0 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               SEQ_ID                         NUMBER             135844247 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               TASK_DATE                      DATE                15916032 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               TASK_RECORD_ID                 VARCHAR2           135844247 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               TASK_RECORD_TYPE               VARCHAR2                   5 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               UPDATED_PERSON                 VARCHAR2               18856 2019-07-06 01:23:43
NCXDX                T_TASK_MAIN               UPDATE_DATE                    DATE                15916032 2019-07-06 01:23:43



col owner for a15 
col table_name for a15 
col column_name for a30 
col data_type for a15 
col low_value for a30 
col high_value for a30 
col id for 999 
col density for 9.999999999999 
col histogram for a15 
set linesize 300 pagesize 900
select column_id id, column_name, data_type,DATA_LENGTH LENGTH,num_distinct, density,NUM_NULLS, histogram, low_value, high_value 
from dba_tab_columns 
where table_name=upper('&table') 
and owner=upper('&owner') 
order by column_id; 


Enter value for table: T_TASK_MAIN
old   3: where table_name=upper('&table')
new   3: where table_name=upper('T_TASK_MAIN')
Enter value for owner: NCXDX
old   4: and owner=upper('&owner')
new   4: and owner=upper('NCXDX')

  ID COLUMN_NAME                    DATA_TYPE           LENGTH NUM_DISTINCT         DENSITY  NUM_NULLS HISTOGRAM       LOW_VALUE                      HIGH_VALUE
---- ------------------------------ --------------- ---------- ------------ --------------- ---------- --------------- ------------------------------ ------------------------------
   1 SEQ_ID                         NUMBER                  22    135844247   .000000007361          0 NONE            C60B63240A5103                 C60D3D0C4A2C03
   2 TASK_RECORD_ID                 VARCHAR2                20    135844247   .000000007361          0 NONE            323031383031303631303938333530 323031393037303531323630313137
   3 TASK_RECORD_TYPE               VARCHAR2                 4            5   .200000000000          0 NONE            3130                           34
   4 CONTACT_TYPE                   VARCHAR2                 4            2   .500000000000          0 NONE            3131                           3132
   5 CONTACT_ID                     VARCHAR2                20    134676480   .000000007425    1796394 NONE            323031383031303630303135303933 756E646566696E6564
   6 TASK_DATE                      DATE                     7     15916032   .000000062830          0 NONE            78760106023536                 78770705173730
   7 MIGRATION_MARK                 VARCHAR2                20            0   .000000000000  135844247 NONE
   8 CREATE_PERSON                  VARCHAR2                20        18856   .000053033517          0 NONE            30303030303032                 5A4A4730313233
   9 CREATE_DATE                    DATE                     7     15916032   .000000062830          0 NONE            78760106023536                 78770705173730
  10 UPDATED_PERSON                 VARCHAR2                20        18856   .000053033517          0 NONE            30303030303032                 5A4A4730313233
  11 UPDATE_DATE                    DATE                     7     15916032   .000000062830          0 NONE            78760106023536                 78770705173730

11 rows selected.





19:21:10 DBADM@cxdx>col index_name format a30
19:21:10 DBADM@cxdx>col column_name format a20
19:21:10 DBADM@cxdx>col tablespace_name format a15
19:21:10 DBADM@cxdx>col index_type format a17
19:21:10 DBADM@cxdx>col column_expression format a20
19:21:10 DBADM@cxdx>col column_position heading 'COLUMN|POSITION'
19:21:10 DBADM@cxdx>select a.table_owner,a.table_name,a.index_name,a.column_name,b.tablespace_name,b.index_type,c.column_expression
19:21:10   2  from dba_ind_columns a,dba_indexes b,dba_ind_expressions c
19:21:10   3  where a.index_name = b.index_name
19:21:10   4  and a.index_name=c.index_name(+)
19:21:10   5  and a.table_name=c.table_name(+)
19:21:10   6  and a.column_position=c.column_position(+)
19:21:10   7  and a.table_name = upper('&table_name')
19:21:10   8  order by a.index_name,a.column_position;
Enter value for table_name: T_TASK_MAIN
old   7: and a.table_name = upper('&table_name')
new   7: and a.table_name = upper('T_TASK_MAIN')

TABLE_OWNER                    TABLE_NAME      INDEX_NAME                     COLUMN_NAME          TABLESPACE_NAME INDEX_TYPE        COLUMN_EXPRESSION
------------------------------ --------------- ------------------------------ -------------------- --------------- ----------------- --------------------
NCXDX                          T_TASK_MAIN     PK_T_TASK_MAIN                 TASK_RECORD_ID       CXDX_BIZ_CAR_ID NORMAL

Elapsed: 00:00:00.26
19:21:24 DBADM@cxdx>select LAST_ANALYZED,INDEX_NAME,status  from dba_indexes where INDEX_NAME='&IDX_NAME';
Enter value for idx_name: PK_T_TASK_MAIN
old   1: select LAST_ANALYZED,INDEX_NAME,status  from dba_indexes where INDEX_NAME='&IDX_NAME'
new   1: select LAST_ANALYZED,INDEX_NAME,status  from dba_indexes where INDEX_NAME='PK_T_TASK_MAIN'

LAST_ANALYZED       INDEX_NAME                     STATUS
------------------- ------------------------------ --------
2019-07-06 01:27:16 PK_T_TASK_MAIN                 VALID

Elapsed: 00:00:00.01
19:21:41 DBADM@cxdx>set linesize 200 pagesize 900                                                                                               
19:22:05 DBADM@cxdx>col column_name for a30                                                                                                     
19:22:05 DBADM@cxdx>col index_name for a30                                                                                                      
19:22:05 DBADM@cxdx>col density for 0.9999999999999                                                                                             
19:22:05 DBADM@cxdx>col index_type for a10                                                                                                      
19:22:05 DBADM@cxdx>col tablespace_name for a30                                                                                                 
19:22:05 DBADM@cxdx>col density for 9.999999999999                                                                                              
19:22:05 DBADM@cxdx>col histogram for a15                                                                                                       
19:22:05 DBADM@cxdx>select a.index_name, a.column_position, a.column_name, a.char_length, a.descend, b.num_distinct, b.density, b.histogram     
19:22:05   2  from dba_ind_columns a, dba_tab_columns b                                                                                   
19:22:05   3  where a.table_name =upper('&table')                                                                                         
19:22:05   4  AND a.TABLE_OWNER=upper('&owner')                                                                                           
19:22:05   5  and a.table_name=b.table_name                                                                                               
19:22:05   6  and a.table_owner=b.owner                                                                                                   
19:22:05   7  and a.column_name=b.column_name                                                                                             
19:22:05   8  order by index_name, column_position, column_name;                                                                          
Enter value for table: T_TASK_MAIN
old   3: where a.table_name =upper('&table')
new   3: where a.table_name =upper('T_TASK_MAIN')
Enter value for owner: NCXDX
old   4: AND a.TABLE_OWNER=upper('&owner')
new   4: AND a.TABLE_OWNER=upper('NCXDX')

                                   COLUMN
INDEX_NAME                       POSITION COLUMN_NAME                    CHAR_LENGTH DESC NUM_DISTINCT         DENSITY HISTOGRAM
------------------------------ ---------- ------------------------------ ----------- ---- ------------ --------------- ---------------
PK_T_TASK_MAIN                          1 TASK_RECORD_ID                          20 ASC     135844247   .000000007361 NONE





















