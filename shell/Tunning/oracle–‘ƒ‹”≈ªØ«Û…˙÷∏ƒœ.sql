oracle性能优化求生指南
————————————————————————————————————————————————————————————
#使用提示改变访问路径：
#使用EMP_MANAGER_IX索引：
	select /*+ index(e emp_manager_ix) */ employee_id,first_name,last_name
	from hr.emloyee emloyee e
	where manager_id=100 and department_id=90;

#指定多个索引名称，指示优化器在一组索引中来选择适当的索引：
select /*+ index(e emp_manager_ix emp_department_ix) */ *
from hr.emloyee e
where manager_id=100 and department_id=90;

#如果你想指定使用索引，让优化器来选择适当的索引：
select /*+ index(e) */  *
from hr.emloyee e 
where manager_id=100 and department_id=90;

#如果不想使用索引，可以使用FULL提示。同时应该检查一下直方图、数据库配置和系统统计信息的使用。
select /*+ full(e) */  *
from hr.emloyee e 
where manager_id=100 and department_id=90;


#使用提示来改变联结顺序：
#ordered提示优化器按照表出现在from子句中的顺序联结表：
select  /*+ ordered */ *
from hr.emloyee e join hr.department d
using (department_id);

#leading提示在不对表出现在from子句中的顺序做特殊要求的情况下达到相同的结果，在leading提示中列出的表排在联结顺序的首位，并且按照在提示中指定的顺序进行联结。例：
select /*+ leading(e) */ *
from hr.emloyee e  join hr.department d 
using(department_id);

#我们可以使用USE_NL/USE_HASH/USE_MERGE提示来选择联结方法（嵌套循环，合并排序或散列）。
#使用hash联结：
select /*+ use_hash(e) */ *
from hr.department_id d join hr.emloyee e 
using (department_id);

————————————————————————————————————————————————————————————
#SQL概要和SQL调优顾问：
BEGIN
	:v_tast_name := DBMS_SQLTUNE.create_tuning_task(sql_id => :v_sql_id);
	DMBS_OUTPUT.put_line(:v_task_name);
	DBMS_SQLTUNE.execute_tuning_task(:v_task_name);
	commit;
END;

可以使用DBA_ADVISOR_LOG视图跟踪它的过程。

#获取调优报告：
select dbms_sqltune.report_tuning_task('TASK_7281') from dual;

#表访问调优：
单表查询是更复杂的SQL查询的组成部分，因此，理解如何优化单表查询是提升更复杂查询的性能的前提。
select * 
from customers_sv c
where cust_year_of_birth = :year_of_birth;
解决这样的查询主要有两种方法：读表中的所有记录查找匹配的值，或利用索引或聚簇的形式更加直接地找出匹配的记录。
最有效的方法将取决于where子句条件的选择性。
一般来说where子句的条件选择性不是很高时，全表扫描是最合适的检索路径。
而在条件的选择性很高时，索引或聚簇方法将更合适。

如下因素会影响到索引检索：
缓冲区高速缓存命中率
记录大小
数据分布

1.优化器如何在索引扫描和全表扫描件选择：
进行全表扫描需要读取的数据库数目。
进行索引查询需要读取的数据块数目。这主要基于对where子句谓词返回的记录数目的估计。
进行全表扫描时多块多的相关开销，以及为满足索引查询进行的单块读的开销。
内存中对缓存中的索引快和数据块数目的假设。

————————————————————————————————————————————————————————————
避免“意外的”的表扫描-——索引失效：
即使存在适当的索引或散列检索路径，由于SQL语句的写法，优化器也有可能无法利用这些访问路径。
1.不等条件
	如果使用了不等操作符 （<> !=或^=），那么oracle一般不会使用索引。这通常是合理的，因为在检索了匹配一个唯一值的记录以外的其他所有记录时，全表扫描是获取数据的最快方法。
2.空值查询
	当索引中的数据都为空值时，B数索引中的条目不会被创建。
	不能使用某个列上的B数索引来查找空值。除非对于这一列重新定义为非空，并用一个默认值来定义空值。
	（避免对索引列进行空值检索。替代的方法是将列定义成非空，并设置默认值，然后用默认值进行检索。）
3.可以使用索引查找非空值。如果大多数的值是空的，那么索引将会很小，而且十分高效，因为空值是不会被索引的。

4.无意中通过使用函数而禁用了索引（如果通过函数或表达式来操纵列，那么优化器将无法使用该列上的索引）：
如下例中，TIME_ID列上有索引，但是因为TIME_ID被包含在一个表达式中，索引将不能被使用：
select sum(accout_sold)
from sales_f
where (sysdate - time_id) <10;
可改写：
select sum(accout_sold)
from sales_f
where time_id > (sysdate-10);

避免在where子句中的索引列应用函数或操作。取而代之的是，在与索引进行比较的值上应用函数或操作。
如果无法避免在索引列上使用函数，可以创建一个函数索引。
在where子句中，需要对列使用函数或表达式是，函数索引是避免索引失效的关键技术。

当使用函数索引，可以考虑对函数索引表达式收集Oracle11g的扩展统计。有助优化器对于是否使用函数索引做出更好的决策。

创建函数所以和扩展统计的另外一种方法是：基于响应的表达式创建oracle11g的虚拟列。通过基于我们的函数创建一个虚拟列，优化器就可以在不收集扩展统计的情况下对基数做出精确的估计。
alter table customer_fi add cust_generation generated alwas as (f_generation(cust_year_of_birth));
在11g中，加上索引的虚拟列可以替换函数索引。使用虚拟列不需要对函数索引表达式收集扩展优化器统计。
————————————————————————————————————————————————————————————

多列查询：
		当where子条件中有多个条件时，我们可以用如下办法完成这个查询：
			对选择性最高的列使用单列索引。
			对where子句中引用的两列或多列使用组合索引。
			使用多个索引合并结果。
			使用全表扫描。
1.使用组合索引：
	 如果查询一个表中的多列值，对所有这些值的组合索引通常是最高效的检索方式。
	 如果具备以下特点，组合索引就是经过优化的：
		 它包含where子句中涉及的表的所有列。
		 组合索引中列的顺序支持最广范围的查询。
		 在适当的时候，使用了索引压缩。
		 如果可能，组合索引包含select列表和where子句中涉及的列。
2.索引合并：
	 oracle 可能使用多个索引处理多个列的查询。在进行索引合并是，oracle可能将索引条目转化成位图，然后使用位图操作合并结果。
	 重点：
	 1.索引合并通常没有组合索引高效，如果相关的列选择性不高（唯一值的数目较低）则性能可能低于全表扫描。
	 2.而对选择性不高的列来说，位图索引合并会更加高效。但是切记，位图索引会带来显著的锁开销。
3.唯一性与覆盖索引：
	 















