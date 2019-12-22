CREATE OR REPLACE PROCEDURE print_table(p_query IN VARCHAR2) 
AUTHID  CURRENT_USER 
IS 
  l_thecursor   INTEGER DEFAULT dbms_sql.open_cursor; 
  l_columnvalue VARCHAR2(4000); 
  l_status      INTEGER; 
  l_desctbl     dbms_sql.desc_tab; 
  l_colcnt      NUMBER; 
BEGIN 
    EXECUTE IMMEDIATE 'alter session set  nls_date_format=''dd-mon-yyyy hh24:mi:ss'' '; 
 
    dbms_sql.parse(l_thecursor, p_query, dbms_sql.native); 
 
    dbms_sql.describe_columns (l_thecursor, l_colcnt, l_desctbl); 
 
    FOR i IN 1 .. l_colcnt LOOP 
        dbms_sql.define_column (l_thecursor, i, l_columnvalue, 4000); 
    END LOOP; 
 
    l_status := dbms_sql.EXECUTE(l_thecursor); y
 
    WHILE ( dbms_sql.Fetch_rows(l_thecursor) > 0 ) LOOP 
        FOR i IN 1 .. l_colcnt LOOP 
            dbms_sql.column_value (l_thecursor, i, l_columnvalue); 
 
            dbms_output.Put_line (RPAD(L_desctbl(i).col_name, 30) 
                                  || ': ' 
                                  || l_columnvalue); 
        END LOOP; 
 
        dbms_output.put_line('-----------------'); 
    END LOOP; 
 
    EXECUTE IMMEDIATE 'alter session set nls_date_format=''dd-MON-rr'' '; 
EXCEPTION 
  WHEN OTHERS THEN 
             EXECUTE IMMEDIATE 
             'alter session set nls_date_format=''dd-MON-rr'' '; 
 
             RAISE; 
END; 
/ 


------------------------
/*
exec print_table('select * from v$lock_type where type=''TA''');

set serveroutput on size 99999;
execute print_table('select * from v$session where sid=997');

exec print_table('select index_name,uniqueness,blevel,leaf_blocks,distinct_keys,num_rows,avg_leaf_blocks_per_key,
avg_data_blocks_per_key,clustering_factor,global_status,user_stats,sample_size,to_char(t.last_analyzed,''yyyy-mm-dd'') 
aly_d from dba_indexes t where table_name=''&TABLE_NAME'' and index_name=''&INDEX_NAME''');
 */


