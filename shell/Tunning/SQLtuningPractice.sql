#SQLtuningPractice
#chapter1
	--ways:
--1.1优化的第一步往往查看相关对象的统计信息，准确的统计信息是优化器优化的必要条件。
		--分区机制是oracle针对大数据的重要解决手段，对于分区表、索引来说，很容易出现因更新不及时出现cost 0的情况，进而导致错误的执行计划。
    --索引 count(*)
    --位图索引可以按很高密度存储数据，因此往往比B数索引小很多。前提是基数比较小。位图索引是保存空值的，因此可以在count中利用。
    --优化没有止境，对数据库了解越多，你能想到的方法就越多，根据场景来优化。
--案例：SQL突然变慢，数据量没有发生变化，表结构也没有发生变更。（insert插入400多万条，目标表7亿万多条记录，物理大小380G，用时12分钟）

--解决过程：
		  1.执行计划异常导致的问题？（固化执行计划）
		  抽取outline的方式，固化执行计划，但没有效果，执行时间是2h.
		  2.缓存问题
		  进一步检查发现，出现“db file sequential read”等待事件。全表扫一般是“db file scattered read”等待事件（buffer缓存
		  大量数据，优化器决定不适用顺序读的方式从文件读取数据。数据版本10g,不能直接干预全表扫描是从缓冲区中读取还是文件中读取
		  。11g是可以的）。建议更换相关作业执行顺序，避免缓冲区干扰。性能还是没有提升。
		  3.究竟是哪个对象导致的？
		  进一步分析SQL执行时的情况，发现忽略了一个关键信息，那就是产生"db file sequential read"等待事件的对象。人们往往想当然
	      的认为全表扫描是表，经检查后是一个索引，目标表的全局索引，相关聚簇银子非常大，接近表的行数。在插入的过程中，要大量的维护索引成本。
	      此表本身还有另外两个索引，都是本地分区索引，维护成本很低。
	      跟开发确认后，该索引是前天临时添加的。没有DBA审核。后续将此索引修改为本地分区索引。恢复正常。
	    
--启发：
		/*优化SQL是一个抽丝剥茧找到问题本质的过程，在不断猜测、不断试错的过程中，逐渐接近事件的本质。
		你所掌握的知识点越多，可猜测的可能性就越多。*/


------------------原理篇----------------------
#chapter2 优化器与成本
	--成本是优化器的重要指标，理解成本、成本如何计算是学习优化器的关键
--2.1CBO的劣势：
	
	 1.多列关联关系
	 2.SQL无关性
	 3.直方图统计信息
	 4.复杂多表关联
	 
	--CBO相关参数
	
	 1.optimizer_mode 可以动态修改
	 2.optimizer_features_enable参数控制使用的优化器特征的版本（不推荐显示设置）
	
	--优化器相关Hint
	 1.all_rows 针对整个SQL启用CBO优化器。格式/*+ all_rows*/
	 2.first_rows(n) 启用CBO，最快响应并返回头n条记录的执行路径。格式/*+ first_rows(n)*/ update、delete、select包含如下会
	 忽略：
	 	 集合运算（如union intersect minus union all）
	 	 group by
	 	 for update
	 	 聚合函数（比如sum等）
	 	 distinct
	 	 order by
	 3.rule 启用RBO。格式：/*+ rule */


--2.2成本
	--只有对成本有更深层次的人事，才能理解优化器的行为，也更容易找出优化器产生较差执行计划的原因。
	 基本概念：语句执行的预计执行时间的总和，以单块读取时间单元的形式来表示
	 计算公式：cost=(#SRDs*sreadtim +#MRDs * mreadtim +#CPUCycles/cpuspeed)/sreadtim
	 公式说明：
	 	1.#SRDs:单数据块读取的次数
	 	2.#MRDs:多数据块读取的次数
	 	3.#CPUCycles:CPU时钟频率。
	 	4.sreadtim:随机读取单数据块的平均时间，单位为毫秒。
	 	5.mreadtim:顺序读取多数据块的平均时间，也就是多数据块平均读取时间，单位为毫秒
	 	6.cpuspeed:代表有负载cpu速度，cpu一秒能处理的操作数，单位是百万次/秒。
	 数据库相关参数：(10053 trace文件中会有相关参数的值)
	 	db_block_size db_file_multiblock_read_count：一次多数据块读取的块数。
	 	streadtim = ioseektim + db_block_size/iotrfrspeed
	 	mreadtim = ioseektim + db_file_multiblock_read_count*db_block_size/iotrfrspeed

#chapter3 执行计划
	--只有充分了解执行计划，才能判断语句执行是否高效。
--3.1概述
	 1.oracle用来执行目标SQL语句的这些步骤的组合被称为执行计划。
	 2.SQL执行计划会缓存到库缓存中（共享池中的一部分），这块内存区域保存的数据结构称为游标，
	   与SQL语句有关的部分是父游标，与语句的执行计划相关的是子游标。每个子游标都有一个序列号，
	   既child_number。第一个child_number为0，相应的oracle会为每个执行计划生成哈希值做区分。
	 3.查看数据库中的执行计划版本：

select sql_text,sql_id,version_count/*表示child_cursor的数量*/
from v$sqlarea
where sql_text like '%insert%';

select distinct sql_id from v$sqlarea;
select plan_hash_value,child_number from v$sql where sql_id='&sql_id';

--3.2解读执行计划
	 1.步骤之间存在父子关系。父子关系通过缩进来体现的，子节点会较父亲节点向右缩进。而父节点就是
	 离它最近的左移节点。
	 2.父子节点之间的缩进结构形成了一个树形图。真正执行顺序是从树形顶部开始，自上而下、自左向右
	 寻找，直到到达某个节点（这个节点没有子节点），首先执行此节点。此后执行此节点同级的节点，执
	 行顺序从上而下。在树形结构中，如果某个节点还有子节点，则新执行子节点；执行结果不断上移到父
	 节点；直到汇总到顶级节点。如图执行顺序：2-4-5-3-1（page44）
     
     --访问路径
     operation列，对应的就是访问路径
     1.表相关的访问路径：
     	 ROWID表扫描
     	 采样表扫描
     	 全表扫描
     2.索引相关的访问路径：
     	  B数索引访问路径
     	  	 索引唯一扫描
     	  	 索引范围扫描
     	  	 索引全扫描
     	  	 索引快速扫描
     	  	 索引跳跃扫描
     	  位图索引访问路径：
     	  	 位图索引单键扫描
     	  	 范围扫描
     	  	 全扫描
     	  	 快速全扫描及按位与、或、减等方式扫描。
     3.表关联相关的方位路径	  	 
     	 嵌套循环连接
     	 排序合并连接
     	 哈希连接
     	 笛卡尔连接
     4.和sort相关的访问路径
     	 聚合
     	 去重
     	 分组
     	 排序 
     5.其他访问路径
     	 视图
     	 集合
     	 层次查询
     /*
     如何理解方位路径：
     	例如，对一个数据表做计数工作，统计有多少条记录。如果才用全表扫描的访问路径，则是
     	按照表中记录的存储顺序，以块为单位，全部访问所有数据记录。
      */	 
--3.3执行计划操作
	 1.查看执行计划的方法：

		 1.1 EXPLAIN PLAN 
		 语法：
		 explain plan {set statement_id='<your id>'}
		 {into table <table_name>}
		 for <sql statement>

		 参数说明：
		 	 sql statement:指定需要提供执行计划的SQL。支持select/insert/update/merge/delete/
		     create tabe/create index/alter index.
		     statement_id:指定一个名字，用来区分存储在计划表中的多个执行计划。
		     table_name:指定计划表的名字。默认plan_table.
		 相关权限：
		 	 数据库执行explain plan语句时，必须对作为参数传递过来的SQL有执行权限。当SQL中有视图时，
		 	 也需要该用户对视图所基于的基表及视图有访问权限。
		 其他说明：
		 	 explain plan是DML语句，而不是DDL语句。不会对当前事务进行隐式提交，仅仅是插入几条记录到计划表。

		 查看执行计划：
		 	 调用dbms_xplan.display
		 	 explain paln for select ....;
		 	 select * from table(dbms_xplan.display);

		 执行计划中的参数：
		 	 COST：CBO这一步消耗的资源。
		 	 ROWS: 计划中这一步处理的行数。
		 	 BYTES:CBO这一步处理的所有记录的字节数，是估算值。
		 	 ROWID:伪列，表中并不物理存储。一旦一行数据插入数据库，rowid在该行的生命周期是唯一的，即使该行
		 	 发行迁移，行的rowid也不会变。
		 	 RECURSIVE SQL:执行用户发出的SQL语句,ORACLE必须执行一些额外的语句，我们将这些额外的成为recursive
		 	 calls。一个DDL语句发出后，oracle总是隐含发出一些recursive SQL语句，来修改字典信息。DML语句和select
		 	 都可能引起recursive SQL。
		 	 ROW SOURCE:行源。在查询中，上一级操作返回的符合条件的行的集合，既可以是表的全部行的集合，也可以
		 	 是表的部分行的集合，还可以是对前两个row source进行连接操作后得到的数据集合。
		 	 PREDICATE:谓词。一个查询中的where限制条件。
		 	 DRIVING TABLE:驱动表，又称为外层表outer table。这个概念用于嵌套和哈希连接中。row source返回较多
		 	 的数据，则对后续操作有负面影响。如果大表有效过滤数据（where限制条件），则大表作为驱动表也是合适的。
		 	 应用查询的限制条件后，返回较少行源的表做驱动表。执行计划中，应该靠上的那个row source进行连接操作
		 	 后得到的数据集合。row source1
		 	 PROBED TABLE:被探查表。该表又称内层表INNER TABLE。在我们从驱动表中得到具体一行的数据后，在该表中
		 	 寻找符合连接条件的行。所以该表应当为大表且响应列上应该有索引。row source2
		 	 CONCATENATED INDEX:组合索引。由多个列构成的索引。引导列，在创建索引的时候处于第一个位置的列。限制
		 	 条件包含引导列，才可以使用该索引。
		 	 SELECTIVITY:可选择性。比较一下列中唯一键的数量和表中的行数，就可以判断该列的可选择性。唯一键/表行数
		 	 比值越接近1，可选择性越好。选择性越好，越适合创建索引。

     	 1.2 AUTOTRACE

     	 一种比较简单的获取执行计划的方式，往往是最常用的方法。调优的时候经常用
     	 有一点需要注意：使用不同选项，决定了是否真正执行这条SQL，其对应的执行计划可能是真实的，也有可能是虚拟的，要加以区分。
     	 当使用autotrace的时候，oracle实际启用了两个会话连接。一个会话用于执行查询，另一个会话用于记录执行计划和最终输出的结果
     	 。进一步发现这两个会话是由同一个进程派生出来的。（一个进程对应多个会话）

     	 常用选项：
     	 SET AUTOTRACE OFF:不生成AUTORACE报，这是默认模式。
     	 SET AUTOTRACE ON EXPLAIN:AUTOTRACE只显示优化器执行路径报告。显示输出。
     	 SET AUTOTRACE ON STATISTICS:只显示统计信息，显示输出
     	 SET AUTOTRACE ON:包含执行计划和统计信息。缺点：执行成功后才返回执行计划，使优化的周期大大增长。
     	 SET AUTOTRACE TRACEONLY:同SET AUTOTRACE ON,但不显示查询输出。这样还是执行语句。一般不用这种方法。
     	 SET AUTOTRACE TRACEONLY EXPLAIN:对于select命令不会执行，只是产生执行计划。不显示输出，但是对于DML操作，还是会执行语句。
     	 有利于优化SELECT语句，减少优化时间。但不会产生statistics数据，statistics数据的物理I/O次数可以判断语句执行效率的优劣。
     	 SET AUTOTRACE TRACEONLY STATISTICS:只显示统计信息。

     	 统计信息参数详解：
     	 COST：CBO这一步消耗的资源。
		 ROWS: 计划中这一步处理的行数。
		 BYTES:CBO这一步处理的所有记录的字节数，是估算值。
		 db blocks gets:用当前方式从缓冲区高速缓存中读取的总块数。
		 consistent gtes:--在缓冲区高速缓存中被请求进行读取的块数。读取方式为一致性读。一致性读可能需要读取回滚段的信息。
		 physical reads：从数据文件到缓冲区高速缓存物理读取的数目。
		 REDO size：语句执行过程中产生的重做信息的字节数。
		 bytes sent via SQL*Net to client:从服务器发送到客户端的字节数。
		 sorts（memory）:在内存中的排序次数。
		 sorts(disk):磁盘排序次数
		 rows processed:更改或选择返回的行

	 	 1.3 SQL Trace（10046）

	 	 辅助诊断工具，SQL跟踪放。记录到trace文件里。
	 	 10046事件是oracle提供的内部事件，是对SQL_TRACE的增强。用于高于1的等级，也称为扩展的SQL跟踪。级别越高，粒度越细。

	 	 级别描述：
	 	 	 0：停用SQL跟踪（相当于SQL_TRACE=FALSE）
	 	 	 1: 标准SQL跟踪（相当于SQL_TRACE=TRUE)。针对每个被处理的数据库调用，给定如下信息：
				 SQL语句
				 响应时间、服务时间
				 处理的行数
				 逻辑读数量、物理读与写的数量
				 执行计划以及额外信息
			 4: 在level 1 的基础上增加绑定变量的信息，主要是数据类型、精度及每次执行时所用的值
			 8: 在level 1 的基础上增加等待事件的信息，包括等待事件的名称、持续时间及一些额外的参数
			 12: 同时启动level 4 + 8
		 
		 使用方法：
		 	 提前设置参数：
		 	 	 如果将statistics_level设定为basic，timed_statistics默认为false；否则timed_statistics TRUE
		 	 	 max_dump_file_size unlimited
		 	 默认规则：
		 	 	 instancename_processname_processid.trc
		 	 	 process id 操作系统的进程标识，可以通过v$process视图的spid列获得。
		 	 人工标记文件：
		 	 	 alter session set tracefile_identifier='test';
		 	 	 alter sesson sql_trace=true;
		 	 	 名称格式：instancename_processname_processid_<tracefile_identifier>.trc
		 	 文件路径：
		 	 	 跟踪文件的位置：backupground_dump_dest确定。11g查看方法：
		 	 	 	select value from v$parameter where name='diagnostic_dest';
		 	 	 	select value from v$diag_info where name='Default Trace';(//跟踪目录)
		 	 	 	select value form v$diag_info where name='Default Trace File';(//跟踪文件)
		 	 操作步骤：
		 	 	 避免使用全局，本身消耗资源。
		 	 	 开启方法有两种：
		 	 	 	 alter session set sql_trace=true;
		 	 	 	 alter session set sql_trace=false;
		 	 	 	 alter session set events '10046 trace name context forever,level 12';
		 	 	 	 alter session set events '10046 trace name context off';
		 	 	 跟踪其他用户会话：
		 	 	 	 exec dbms_system.set_sql_trace_in_session(&sid,&serial,true);
		 	 	 	 exec dbms_system.set_sql_trace_in_session(&sid,&serial,false);
		 	 	 提供其他用户在任意会话内激活或禁止SQL跟踪的能力，dbms_support
		 	 	 	 exec dbms_support.start_trace_in_session(sid => 1234,serial# => 56789,binds=true); 
		 	 	 	 exec dbms_support.stop_trace_in_session(sid => 1234,serial# => 56789,)	
		 使用方法（新方式）
		 	 会话级
		 	  	 开启
		 	  	 dbms_monitor.session_trace_enable(session_id=>&sid,serial_num=>&serial_num,waits=>true,binds=>false);
		 	  	 dbms_monitor.session_trace_disable(session_id=>&sid,serial_num=>&serial_num);
		 	  	 查看会话是否被跟踪（rac要在所在会话的实例上）
		 	  	 select sql_trace,sql_trace_waits,sql_trace_binds
		 	  	 from v$session
		 	  	 where sid=xxx;
		 	 客户端级：
		 	 	 dbms_monitor.client_id_trace_enable(client_id='',wait=>true,bind=>false);
		 	 	 dbms_monitor.client_id_trace_disable(client_id='');
		 	 参数说明：
		 	 	 client_id：没有m默认值
		 	 	 waits:是否跟踪等待事件，默认为true
		 	 	 binss:是否跟踪绑定变量，默认为false
		 	 查看客户端是否被跟踪：
		 	 	 select primary_id as client_id,waits,binds
		 	 	 from dba_enable_traces
		 	 	 where trace_type='CLIENT_ID';	
		 分析日志
		 	 原始日志，处理后的日志有些信息会丢失。
		 	 日志指标进行说明：
		 	 	 1）PARSING IN CURSOR ...END OF STMT:主要记录SQL语句文本。
		 	 	 	 len:被分析SQL的长度
		 	 	 	 dep:产生递归SQL的深度
		 	 	 	 uid:user id.
		 	 	 	 otc:oracle command type命令的类型。
		 	 	 	 lid:私有用户的ID。
		 	 	 	 tim:时间戳。
		 	 	 	 hv:hash value
		 	 	 	 ad:sql address
		 	 	 2)PARSE表示解析，EXEC表示执行，FETCH表示获取
		 	 	 	 c:消耗的CPU time
		 	 	 	 e:elapsed time操作的用时
		 	 	 	 p:physical reads物理读的次数
		 	 	 	 cr:consistent raads一致性方式读取的数据块
		 	 	 	 cu:current方式读取的数据块
		 	 	 	 mis:cursor miss in cache硬解析次数
		 	 	 	 r:rows处理的行数
		 	 	 	 dep:depth递归SQL的深度。
		 	 	 	 og:optimizer goal优化器模式。
		 	 	 	 tim:timestamp时间戳
		 	 	 3)BINDS:绑定变量的定义和值。
		 	 	 4)WAIT:在处理过程中的等待事件。
				 5)STAT:产生的执行计划以及相关的统计。
					 id:执行计划的行源号
					 cnt:当前行源返回的行数
					 pid:当前行源的父号
					 pos:执行计划的位置。
					 obj:当前操作的对象ID
					 op:当前行源的数据访问操作

			 TKPROF日志
			 	 把原始日志转化成容易阅读的日志。
			 	 指标分析：
			 	 1）纵行
			 	 	 parse（分析）
			 	 	 execute（执行）
			 	 	 fetch（提取）
			 	 2）横行
			 	 	 count（计数）
			 	 	 CPU:消耗的CPU时间
			 	 	 ELAPSED:消耗的时间，大于CPU时间，则意味着等待事件。
			 	 	 DISK(磁盘)：物理读的数据块数量。不是物理IO的数量
			 	 	 QUERY(查询)：在一致性读模式下从高速缓存逻辑读取的块数量。
			 	 	 CURRENT(当前)：在当前模式下从高速缓存逻辑读取的块数量。通常这类逻辑读被insert、delete、merge及update使用。
			 	 	 ROWS(行)：所有SQL语句返回的记录数目，但是不包括子查询中返回的记录数目。SELECT,在fetch步。dml，在execute。
			 	 3）查询环境
			 	 	 "misses in library cache during parse:n" :是否在库中进行了解析（0为软解析，1为硬解析）
			 	 	 "misses in library cache during execute:n":执行调用阶段硬解析的数量。
			 	 	 "Optimizer goal:xxx":优化器模式
			 	 	 "Parsing user id:xxx":解析SQL语句用户ID
			 	 	 "(recursive depth: n)"：递归深度。只针对递归SQL语句提供。
			 	 4）查询计划
			 	     两部分：如果指定了explain参数的话可能会看到两部分。第一部分行源操作，是游标关闭且开启跟踪情况下写到跟踪文件
			 	     中的执行计划。第二部分成为执行计划，是由指定explain参数的tkprof生产的，如果不一致，前者是正确的。
			 	     统计信息：
			 	     cr:一致性模式下逻辑读出的数据块数	
			 	     pr:磁盘物理读出的数据块数
			 	     pw:物理写入磁盘的数据块数
			 	     time:百万分之一秒记得占用事假，us代表微秒。
			 	     cost:操作的开销评估。
			 	     size:操作返回的预估数据量。
			 	     card:操作返回的预估行数。
			 	 5）等待事件：总结了SQL语句的等待事件，每种等待事件提供了如下值：
			 	 	 Time Waited:等待事件占用时间。
			 	 	 MaxWait:单个等待事件最大等待时间，单位为秒。
			 	 	 Total Wait:针对一个等待事件总的等待秒数。
			 	 6）跟踪文件信息：跟踪文件的相关信息
			 	 	 跟踪文件名、版本号，用于这个分析所使用的参数sort值
			 	 	 所有会话数量与SQL语句数量
			 	 	 组成跟踪文件的行数。
		 1.4 V$SQL V$SQL_PALN不推荐
		 1.5 DBMS_XPLAN 
		 	 数据库内置包，可以查看存储在不同位置的执行计划。
		 	 调用方法：
		 	 	 DISPLAY 使用explain plan，数据源计划表
		 	 	 DISPLAY_CURSOR real plan,库缓存中的游标缓存
		 	 	 DISPLAY_AWR history，AWR仓库基表WRH$SQL_Plan 
		 	 	 DISPLAY_SQLSET SQL Tuning set,SQL set视图
		 	 
		 	 	1.5.1DBMS_XPLAN.DISPLAY
		 		 语法:
		 	 	 select * from table(dbms_xplan.display('table_name','statement_id','format','filter_preds'));
		 	 	 参数说明：
		 	 	 table_name：指定计划表的名字，默认值为plan_table.
		 	 	 statement_id:指定SQL语句的名字，可选参数。默认值null。
		 	 	 format：指定输出哪些内容。基本的basic,typical,serial,all,advanced.如果需要某些特殊的信息，就在
		 	 	 修饰符前可以添加+，比如basic+predicate。如果不需要，就在修饰符前加-。
		 	 	 filter_preds:指定在查询计划表是添加一个约束。默认值null.
		 	 	 	format重点：
		 	 	 		 basic:仅显示很少的信息。基本上只包含操作和操作的对象。
		 	 	 		 typical:显示大部分相关内容。
		 	 	 		 serial:类似typical，没有显示并行
		 	 	 		 all:显示了提纲外的所有信息。
		 	 	 		 advanced:显示所有信息。 
		 	 	 	修饰符：
		 	 	 		 alias:控制包含查询块名和对象别名部分的显示。
		 	 	 		 bytes:控制执行计划表中字段Bytes的显示。
		 	 	 		 cost:控制执行计划表中字段cost的显示。
		 	 	 		 note:控制包含注意信息的部分
		 	 	1.5.2DBMS_XPLAN.DISPLAY_CURSOR
		 	 	 语法：
		 	 	 select * from  (dbms_xplan.display_cursor('sql_id',cursor_child_no,'format'));
		 	 	 参数说明：
		 	 	 sql_id:指定被返回执行计划的SQL语句的父游标。默认是null.。默认当前会话的最后一条SQL语句的执行计划。
		 	 	 cursor_child_no:父游标下子游标的序号。
		 	 	 format：指定输出哪些内容。默认：typical。可用参数和display相同。此外如果执行统计打开(参数statistics_level all或语句使用
		 	 	 了提示gather_paln_statistics),则可以显示更多的信息。
		 	 	 修饰符：
		 	 	 	 allstats:这是iostats+memstats的快捷方式
		 	 	 	 iostats:控制IO统计的显示.
		 	 	 	 last:显示所有执行计算过的统计。如果指定了这个值，只显示最有一次执行的统计信息。
		 	 	 	 memstats；控制PGA相关统计的显示。
		 	 	 	 示例：
		 	 	 	 	 select count(*) from t1;
		 	 	 	 	 select sql_id,address,hash_value,plan_hash_value,child_number
		 	 	 	 	 from v$sql
		 	 	 	 	 where sql_text like '%%' and sql_text not lie '%v$sql%';
		 	 	 	 	 select * from table(dbms_xplan.display_cursor('&sql_id',null,'allstats'));
		 	 	1.5.3 DBMS_XPLAN.DISPLAY_AWR
		 	 	 语法：
		 	 	  select * from table(dbms_xplan.display_awr('sql_id',plan_hash_value,db_id,'format'));
		 	 	 参数： 
		 	 	 	sql_id:指定被返回执行计划的SQL语句的父游标。此参数没有默认值
		 	 	 	plan_hash_value:指定被返回执行计划的SQL语句的哈希值默认null
		 	 	 	db_id:指定数据库。默认为null,当前数据库。
		 	 	 	format：指定要显示哪些信息。和display有相同参数。默认typical。
		 	 	 执行计划字段说明：
		 	 	 	ID:每一个操作的标识符。带*号的将提供这个行包含的谓词信息。
		 	 	 	Operation:执行的操作，又称为行源操作。
		 	 	 	Name:操作的对象	
		 	 	 	Rows(E-Rows):评估中返回的记录条数。
		 	 	 	Rows(E-Bytes)：评估中操作返回的字节数。
		 	 	 	TempSpc:评估中操作使用的临时表空间大小。
		 	 	 	Cost(%CPU):评估中操作的开销。
		 	 	 	Time:评估中执行需要的时间（HH:MM:SS）
		 	 	 分区：
		 	 	 	pstart:访问的第一个分区。
		 	 	 	pstop:访问的最后一个分区。
		 	 	 并行和分布式处理：
		 	 	    Inst:在分布式操作中，指操作使用的数据库链的名字。
		 	 	    TQ:在并行操作中，用于从属线程间通信的表队列。
		 	 	    IN-OUT:并行或分布式操作间的关系。
		 	 	    PQ Distrib:在并行操作中，生产者为发送数据给消费者进行的分配。
		 	 	 运行时统计（统计开启时启用）：
		 	 	 	starts：指定操作执行的次数
		 	 	 	rows:操作返回的真实记录数
		 	 	 	TIME:操作执行的真实时间
		 	 	 IO统计（统计开启时应用）
		 	 	 	buffer:执行期间进行的逻辑读操作数量。
		 	 	 	reads:执行期间进行的物理读操作。
		 	 	 	writes:执行期间进行的物理写操作数量。	
		 	 	 内存使用统计：
		 	 	 	Used_MEM:最后一次执行时操作使用的内存量
		 	 	 	Used_Tmp：操作使用的最大临时空间大小。
		 	 	 涉及的查询块
		 	 	 outline
		 	 	 Predicate Information 谓词。一个查询中的where限制条件。
		 	 	 Column Projection Information:显示每一步操作执行，哪些字段作为输出返回。

--3.4 固定执行计划
	 
	 Hint	
	 存储概要（store outline）
	 SQL profile
	 SQL计划基线
	 coe_xfr_sql_profile.sql



#chapter4 统计信息
--4.1统计信息分类
	大致分为系统统计信息、对象统计新、数据字典统计信息、内部对象统计信息。
	 --系统统计信息
		1. 非工作量统计信息
		 指标项说明：
		 	 CPUSPEEDNW:代表无负载CPU速度。一个CPU一秒能处理的操作数。单位百万次每秒。
		 	 IOSEEKTIM:IO查找时间，也就是平均寻道时间，其等于查找时间、延迟时间、OS负载时间三者之和，单位为毫秒
		 	 IOTFRSPPED:I/O传输速度，平均每毫秒从磁盘传输的字节数，单位为字节每毫秒。默认4096

		2.工作量统计信息
		 	 CPUSPEED：代表有负载CPU速度。
		 	 SREADTIM:随机读取单数据块的平均时间，单位为毫秒。
		 	 MREADTIM:顺序读取多数据块的平均时间，也就是多数据块平均读取时间，单位为毫秒
		 	 MBRC:平均每次读取的块数量。
		 	 MAXTHR:最大IO吞吐量，单位字节/s.
		 	 SLAVETHR：并行处理从属线程的I/O吞吐量，单位字节每秒。
		 查询语句：
		 	 收集状态：
		 	 select pname,pval1,pval2 from sys.aux_stats$ where name='SYSSTATS_INFO';	
		 	 收集结果集：
		 	 select pname,pval1,pval2 from sys.aux_stats$ where name='SYSSTATS_MAIN';	
		3.相关操作：
		 	 收集统计信息：
		 	 针对非工作量的统计信息：
		 	 dbms_stats.gather_system_stats(gathering_mode=>'noworkload');
		 	 针对工作量统计信息收，执行两次收集动作，在两次快照之间计算其差值。
		 	 方法1：
		 	 dbms_stats.gather_system_stats(gathering_mode=>'start');
		 	 wait a moment 30minutes
		 	 dbms_stats.gather_system_stats(gathering_mode=>'stop');
		 	 方法2：
		 	 dbms_stats.gather_system_stats(gathering_mode=>'interval',interval=>N);
		 	 invertval指定收集时间时长。
		 	 设置统计信息：
		 	 begin
			 dbms_stats.delete_system_stats();
    		 dbms_stats.set_system_stats(pname=>'CPUSPEED',pvalue=>772);
			 dbms_stats.set_system_stats(pname=>'SREADTIM',pvalue=>S.5);
 			 dbms_stats.set_system_stats(pname=>'MREADTIM',pvalue=>l9.4);
			 dbms_stats.set_system_stats(pname=>'MBRC',pvalue=>53);
			 dbms_stats.set_system_stats(pname=>'MAXTHR',pvalue=>l243434334);
		 	 dbms_stats.set_system_stats(pname=>'SLAVETHR',pvalue=>1212121);
			 end;
			 删除统计信息：
			 exec dbms_stats.delete_system_stats;
 	 
 	 --对象统计信息
 	 	1.表统计信息
 	 	查看数据字典，得到相关统计信息。
 	 	select table_name,num_rows,blocks,empty_blocks,avg_space,chain_cnt,avg_row_len
 	 	form dba_tables where table_name='&table_name';
 	 	字段说明：
 	 		 num_rows:数据的行数
 	 		 blocks：高水位线下的数据块个数
 	 		 empty_blocks:高水位项以上的数据块个数。DBMS_STATS不计算这个值，被设置为0.


 		













		 	 				 









		 	 	 	 	 


		 	 	 	  	 	 	 


















