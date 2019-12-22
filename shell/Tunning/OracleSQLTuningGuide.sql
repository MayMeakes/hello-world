OracleSQLTuningGuide.sql
-------------------------------------

#SQLruningTimeOrder
set lines 200 pagesize 1000
col sql_id for a30
col child_number 99
col sql_text for a20
select sql_id,child_number,sql_text,elapsed_time/1000000/60 "execute_time(min)"
from (
		select sql_id,child_number,sql_text,elapsed_time,cpu_time,disk_reads,
				rank() over(order by elapsed_time desc) as elapsed_rank
		from v$sql)
where elapsed_rank <= 10
/


#可以从使用绑定变量中获益的SQL语句
set lines 100 pagesize 1000
col sql_text for a30
with force_matches as
	(select force_matching_signature,
		count(*) matches,
		max(sql_id ||child_number) max_sql_child,
		dense_rank() over (order by count(*)desc) ranking
		from v$sql
		where force_matching_signature <> 0
		and parsing_schema_name <> 'SYS'
		group by force_matching_signature
		having count(*)>5)
select sql_id,matches,parsing_schema_name schema,sql_text
from v$sql join force_matches
on (sql_id||child_number=max_sql_child)
where ranking<= 10
order by matches desc;	


#使用存储过程减少应用与数据库的交互次数，减少响应时间
create function calc_discount (p_cust_id number)
	RETURN number
is 
	select quantity_sold,amount_sold,prod_id
		from sh.sales
	where cust_id=p_cust_id;

	v_total_discount NUMBER := 0;
BEGIN
	FOR cust_row in cust_csr
	loop
		v_total_discount :=
		v_total_discount
		+ discountcalc (cust_row.quantity_sold,
						cust_row.prod_id,
						cust_row.amount_sold
						);
	END LOOP;
	RETURN(v_total_discount);
END;



#