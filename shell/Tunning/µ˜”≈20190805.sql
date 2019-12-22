调优20190805.sql
10.197.35.225
92gwjb5jm0c5y	

OWNER                   GB
--------------- ----------
RPT             84.4316406

    SnapId PLAN_HASH_VALUE Date time                      No. of exec        LIO/exec CPUTIM/exec  ETIME/exec        PIO/exec  ROWs/exec 
---------- --------------- ------------------------------ ----------- --------------- ----------- ----------- --------------- ---------- 
     36746      1838694020 08/04/19_0600_0700                       9      9988960.56       44.53      608.93      9987150.00 .888888889
     36747      1838694020 08/04/19_0700_0800                       9     11705348.56       53.62      765.27     11703108.78 1.88888889
     36748      1838694020 08/04/19_0800_0900                       9     11111850.67       51.05      611.75     11109519.78          3
     36749      1838694020 08/04/19_0900_1000                      10     10954297.00       49.89      555.04     10952248.20        3.7
     36750      1838694020 08/04/19_1000_1100                      10     10936430.70       50.18      453.26     10934364.30        4.7
     36751      1838694020 08/04/19_1100_1200                       9     10958005.11       50.49      621.47     10955880.22 6.22222222
     36752      1838694020 08/04/19_1200_1300                      10     10962096.90       50.71      594.36     10960019.00        6.6
     36753      1838694020 08/04/19_1300_1400                       5     10950297.00       52.01      598.31     10948205.00       14.2
	 

OWNER           TABLE_NAME                       NUM_ROWS     BLOCKS T TABLESPACE_NAME                PARTITIONE LAST_ANALYZED
--------------- ------------------------------ ---------- ---------- - ------------------------------ ---------- ------------------
RPT             RB_WJPK_T                       277126500   10906231 N                                YES        27-JUL-19



select /*+parallel(t,8)*/ count(distinct t.branch_company_code) from
rpt.rb_wjpk_t t where trunc(t.list_date,'dd') =
to_date('20190803','yyyymmdd') and t.flag_auto = '0'
   
   
INDEX_NAME                       POSITION COLUMN_NAME                    CHAR_LENGTH DESC NUM_DISTINCT         DENSITY HISTOGRAM
------------------------------ ---------- ------------------------------ ----------- ---- ------------ --------------- ---------------
RB_WJPK_T_IND001                        1 LIST_DATE                                0 ASC           339   .002949852507 NONE   


   
  ID COLUMN_NAME                    DATA_TYPE           LENGTH NUM_DISTINCT         DENSITY  NUM_NULLS HISTOGRAM       LOW_VALUE                      HIGH_VALUE
---- ------------------------------ --------------- ---------- ------------ --------------- ---------- --------------- ------------------             --------------
   1 BRANCH_COMPANY_CODE            VARCHAR2                21           42   .023809523810          0 NONE            31303130313030                 37303630313030
   2 DEPARTMENT_CODE                VARCHAR2                 9         3923   .000254906959       3545 NONE            243031                         5A5A47
   3 SECTION_OFFICE_CODE            VARCHAR2                 9         6547   .000152741714       3545 NONE            243031                         5A5A48
   4 RISK_CATEGORY                  VARCHAR2                 6            7   .142857142857          0 NONE            40                             5348
   5 PRODUCT_CODE                   VARCHAR2                24         1059   .000944287063          0 NONE            3131303130313030               3234303339384C4A
   6 GSJE                           NUMBER                  22       981888   .000001018446          0 NONE            3B6331253836383D66             C50359
   7 CLAIM_FOLDER_NO                VARCHAR2                60      7040000   .000000142045          0 NONE            204538303533373030353030303030 E888B9E888B932303035303038
                                                                                                                       37

   8 INDEMNITY_NO                   VARCHAR2                60       709120   .000001410199  223470651 NONE            393830333230394A333134302D31   5058495A3030493230313830303031
                                                                                                                                                      3039

   9 LIST_DATE                      DATE                     7          339   .002949852507          0 NONE            78760816010101                 7877071A010101
  10 FLAG_AUTO                      VARCHAR2                 1            2   .500000000000          0 NONE            30                             31
  11 CHECK_CURRENT_DATE             DATE                     7        22714   .000044025711          0 NONE            7876081705092E                 787705180A380C
  12 WORKDATE                       VARCHAR2                 8          275   .003636363636          0 NONE            3230313830383232               3230313930353233
  13 POLICY_PRODUCT_CODE            VARCHAR2                24          629   .001589825119          0 NONE            3131303130313030               323430323938303   
   
 
Plan hash value: 1838694020

-------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |    TQ  |IN-OUT| PQ Distrib |
-------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |           |       |       |   264K(100)|          |       |       |        |      |            |
|   1 |  SORT AGGREGATE            |           |     1 |    12 |            |          |       |       |        |      |            |
|   2 |   PX COORDINATOR           |           |       |       |            |          |       |       |        |      |            |
|   3 |    PX SEND QC (RANDOM)     | :TQ10000  |     1 |    12 |            |          |       |       |  Q1,00 | P->S | QC (RAND)  |
|   4 |     SORT AGGREGATE         |           |     1 |    12 |            |          |       |       |  Q1,00 | PCWP |            |
|   5 |      PX PARTITION RANGE ALL|           |    42 |   504 |   264K  (1)| 00:52:54 |     1 |    42 |  Q1,00 | PCWC |            |
|   6 |       VIEW                 | VW_DAG_0  |    42 |   504 |   264K  (1)| 00:52:54 |       |       |  Q1,00 | PCWP |            |
|   7 |        HASH GROUP BY       |           |    42 |   756 |   264K  (1)| 00:52:54 |       |       |  Q1,00 | PCWP |            |
|   8 |         TABLE ACCESS FULL  | RB_WJPK_T | 35577 |   625K|   264K  (1)| 00:52:54 |     1 |    42 |  Q1,00 | PCWP |            |
-------------------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$C33C846D
   6 - SEL$5771D262 / VW_DAG_0@SEL$C33C846D
   7 - SEL$5771D262
   8 - SEL$5771D262 / T@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('11.2.0.4')
      DB_VERSION('11.2.0.4')
      OPT_PARAM('_b_tree_bitmap_plans' 'false')
      OPT_PARAM('_optim_peek_user_binds' 'false')
      OPT_PARAM('_bloom_filter_enabled' 'false')
      OPT_PARAM('_optimizer_use_feedback' 'false')
      OPT_PARAM('optimizer_dynamic_sampling' 7)
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$5771D262")
      TRANSFORM_DISTINCT_AGG(@"SEL$1")
      OUTLINE_LEAF(@"SEL$C33C846D")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$5771D262")
      TRANSFORM_DISTINCT_AGG(@"SEL$1")
      NO_ACCESS(@"SEL$C33C846D" "VW_DAG_0"@"SEL$C33C846D")
      FULL(@"SEL$5771D262" "T"@"SEL$1")
      USE_HASH_AGGREGATION(@"SEL$5771D262")
      END_OUTLINE_DATA
  */

Note
-----
   - dynamic sampling used for this statement (level=7)



   

ATOM	CXIDSDB_TBS	IDX_LIMIT02	P3010100	INDEX PARTITION	553	16.71



col username for a20
select distinct a.user_id,b.username,a.sql_id
from dba_hist_active_sess_history a ,dba_users b 
where a.user_id=b.user_id 
and sql_id='&sql_id';
























——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
fcxwx78rndkxj
	
INSERT INTO R_TMP_3202_13
  SELECT A.BRANCH_COMPANY_CODE,
         D.BRANCH_COMPANY_NAME,
         SUBSTR(:B1, 1, 4) AS NF,
         SUBSTR(:B1, 5, 2) AS QSH,
         A.DEPARTMENT_CODE,
         B.DEPARTMENT_NAME,
         C.DEPARTMENT_GROUP_NAME,
         A.SECTION_OFFICE_CODE,
         F.SECTION_OFFICE_NAME,
         A.PRODUCT_CODE,
         A.RISK_CATEGORY,
         E.XZHMC,
         A.POLICY_NO,
         A.FLAG AS FLAG1,
         A.INCEPTION_DATE,
         A.PLANNED_END_DATE,
         A.BCRZJE AS RZBF,
         A.INSURED_AMOUNT,
         A.TBRMC AS APPLICATION_NAME,
         A.CREDENTIAL_NO,
         A.NUMBER_OF_INSURED_OBJECT,
         A.SELLING_CHANNEL_TYPE,
         A.OPERATOR_CODE,
         A.POLICY_TYPE,
         A.FLAG2,
         A.FLAG3,
         A.ORIGINAL_POLICY_NO AS POLICY_NO_LAST,
         A.ORG_TBRMC AS APPLICATION_NAME_LAST,
         A.ORG_CREDENTIAL_NO AS CREDENTIAL_NO_LAST,
         A.FLAG_NFQSH FLAG,
         I.NAME SELLING_CHANNEL_TYPE_NAME,
         H.STAFF_NAME JBRMC
    FROM R_TMP_3202_12 A,
         BM_T          B,
         ATOM.BMZ_T    C,
         FGS_T         D,
         TYPECOMP_T    E,
         KS_T          F,
         RYDM_T        H,
         ZYFS          I
   WHERE A.BRANCH_COMPANY_CODE = B.BRANCH_COMPANY_CODE(+)
     AND A.DEPARTMENT_CODE = B.DEPARTMENT_CODE(+)
     AND B.BRANCH_COMPANY_CODE = C.BRANCH_COMPANY_CODE(+)
     AND B.DEPARTMENT_GR
   OUP_CODE = C.DEPARTMENT_GROUP_CODE(+)
     AND A.PRODUCT_CODE = E.YXZH(+)
     AND A.RISK_CATEGORY = E.FXLB(+)
     AND A.BRANCH_COMPANY_CODE = D.BRANCH_COMPANY_CODE
     AND A.BRANCH_COMPANY_CODE = F.BRANCH_COMPANY_CODE(+)
     AND A.SECTION_OFFICE_CODE = F.SECTION_OFFICE_CODE(+)
     AND A.BRANCH_COMPANY_CODE = H.BRANCH_COMPANY_CODE(+)
     AND A.OPERATOR_CODE = H.STAFF_CODE(+)
     AND A.SELLING_CHANNEL_TYPE = I.CODE(+)
	 
	 
Plan hash value: 4052165484

------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT             |               |       |       |       |   121K(100)|          |
|   1 |  LOAD TABLE CONVENTIONAL     |               |       |       |       |            |          |
|   2 |   HASH JOIN RIGHT OUTER      |               |   722K|  2444M|       |   121K  (1)| 00:24:16 |
|   3 |    TABLE ACCESS FULL         | KS_T          | 39542 |  1197K|       |    84   (2)| 00:00:02 |
|   4 |    HASH JOIN RIGHT OUTER     |               |   722K|  2423M|       |   121K  (1)| 00:24:15 |
|   5 |     TABLE ACCESS FULL        | BMZ_T         |   611 | 21385 |       |     6   (0)| 00:00:01 |
|   6 |     HASH JOIN RIGHT OUTER    |               |   722K|  2398M|       |   121K  (1)| 00:24:15 |
|   7 |      TABLE ACCESS FULL       | BM_T          | 12393 |   459K|       |    67   (0)| 00:00:01 |
|   8 |      HASH JOIN RIGHT OUTER   |               |   722K|  2372M|       |   121K  (1)| 00:24:14 |
|   9 |       TABLE ACCESS FULL      | TYPECOMP_T    |  4809 |   220K|       |   134   (1)| 00:00:02 |
|  10 |       HASH JOIN              |               |   722K|  2340M|       |   120K  (1)| 00:24:12 |
|  11 |        TABLE ACCESS FULL     | FGS_T         |    46 |  1150 |       |     2   (0)| 00:00:01 |
|  12 |        HASH JOIN RIGHT OUTER |               |   722K|  2323M|    23M|   120K  (1)| 00:24:12 |
|  13 |         TABLE ACCESS FULL    | RYDM_T        |   635K|    16M|       |  1248   (2)| 00:00:15 |
|  14 |         HASH JOIN RIGHT OUTER|               |   722K|  2304M|       |  3867   (2)| 00:00:47 |
|  15 |          TABLE ACCESS FULL   | ZYFS          |    38 |   836 |       |     2   (0)| 00:00:01 |
|  16 |          TABLE ACCESS FULL   | R_TMP_3202_12 |   722K|  2289M|       |  3860   (2)| 00:00:47 |
------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$F5BB74E1
   3 - SEL$F5BB74E1 / KS_T@SEL$2
   5 - SEL$F5BB74E1 / C@SEL$1
   7 - SEL$F5BB74E1 / B@SEL$1
   9 - SEL$F5BB74E1 / E@SEL$1
  11 - SEL$F5BB74E1 / D@SEL$1
  13 - SEL$F5BB74E1 / H@SEL$1
  15 - SEL$F5BB74E1 / I@SEL$1
  16 - SEL$F5BB74E1 / A@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('11.2.0.4')
      DB_VERSION('11.2.0.4')
      OPT_PARAM('_b_tree_bitmap_plans' 'false')
      OPT_PARAM('_optim_peek_user_binds' 'false')
      OPT_PARAM('_bloom_filter_enabled' 'false')
      OPT_PARAM('_optimizer_use_feedback' 'false')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$F5BB74E1")
      MERGE(@"SEL$2")
      OUTLINE_LEAF(@"INS$1")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$2")
      FULL(@"INS$1" "R_TMP_3202_13"@"INS$1")
      FULL(@"SEL$F5BB74E1" "A"@"SEL$1")
      FULL(@"SEL$F5BB74E1" "I"@"SEL$1")
      FULL(@"SEL$F5BB74E1" "H"@"SEL$1")
      FULL(@"SEL$F5BB74E1" "D"@"SEL$1")
      FULL(@"SEL$F5BB74E1" "E"@"SEL$1")
      FULL(@"SEL$F5BB74E1" "B"@"SEL$1")
      FULL(@"SEL$F5BB74E1" "C"@"SEL$1")
      FULL(@"SEL$F5BB74E1" "KS_T"@"SEL$2")
      LEADING(@"SEL$F5BB74E1" "A"@"SEL$1" "I"@"SEL$1" "H"@"SEL$1" "D"@"SEL$1" "E"@"SEL$1"
              "B"@"SEL$1" "C"@"SEL$1" "KS_T"@"SEL$2")
      USE_HASH(@"SEL$F5BB74E1" "I"@"SEL$1")
      USE_HASH(@"SEL$F5BB74E1" "H"@"SEL$1")
      USE_HASH(@"SEL$F5BB74E1" "D"@"SEL$1")
      USE_HASH(@"SEL$F5BB74E1" "E"@"SEL$1")
      USE_HASH(@"SEL$F5BB74E1" "B"@"SEL$1")
      USE_HASH(@"SEL$F5BB74E1" "C"@"SEL$1")
      USE_HASH(@"SEL$F5BB74E1" "KS_T"@"SEL$2")
      SWAP_JOIN_INPUTS(@"SEL$F5BB74E1" "I"@"SEL$1")
      SWAP_JOIN_INPUTS(@"SEL$F5BB74E1" "H"@"SEL$1")
      SWAP_JOIN_INPUTS(@"SEL$F5BB74E1" "D"@"SEL$1")
      SWAP_JOIN_INPUTS(@"SEL$F5BB74E1" "E"@"SEL$1")
      SWAP_JOIN_INPUTS(@"SEL$F5BB74E1" "B"@"SEL$1")
      SWAP_JOIN_INPUTS(@"SEL$F5BB74E1" "C"@"SEL$1")
      SWAP_JOIN_INPUTS(@"SEL$F5BB74E1" "KS_T"@"SEL$2")
      END_OUTLINE_DATA
  */

Note
-----
   - dynamic sampling used for this statement (level=2)


223 rows selected.	 
	 