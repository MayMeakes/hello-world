mysql5.7&5.6
——————————————————————————————————————————————————
 
数据库的基本操作
	 查看当前存在的数据库：
	 show databases;
	 
	 创建数据库：
	 create database database_name;
	 
	 查看创建好的数据库的DDL语句：
	 show create database database_name;\G
	 
	 删除数据库：
	 drop database database_name;
	 
	 数据库存储引擎：
	 show engines;\G
	 
	 登录数据库：
	 mysql -h hostip -u root -p 
	 
	 查看默认存储引擎：
	 [root@localhost][mysql]> show variables like '%engine%';

数据库表的基本操作：
	创建表的语法：
		create table table_name 
		（
		ID int(11),
		name varchar(25),
		deptid int(11),
		salary float
		);
	查看当前数据库里的表：
	 show tables;
	 
	 使用主键约束：
	 create table table_name 
		（
		ID int(11) primary key,
		name varchar(25),
		deptid int(11),
		salary float
		);
		
		create table table_name 
		（
		ID int(11),
		name varchar(25),
		deptid int(11),
		salary float,
		primary key(id)
		);
		
		外键约束：
	 create table table_name 
		（
		ID int(11) primary key,
		name varchar(25),
		deptid int(11),
		salary float，
		constranit fk_emp_dept1 foreign key(deptid) references tb_dept1(id)
		);		
	  
	  非空约束：
	 create table table_name 
		（
		ID int(11) primary key,
		name varchar(25) not null,
		deptid int(11),
		salary float，
		constranit fk_emp_dept1 foreign key(deptid) references tb_dept1(id)
		);	
	
	 唯一性约束：
	 create table table_name 
		（
		ID int(11) primary key,
		name varchar(25) unique,
		deptid int(11),
		salary float，
		constranit fk_emp_dept1 foreign key(deptid) references tb_dept1(id)
		);	
	 
	 默认约束：
	 create table table_name 
		（
		ID int(11) primary key,
		name varchar(25) unique,
		deptid int(11) default 1111,
		salary float，
		constranit fk_emp_dept1 foreign key(deptid) references tb_dept1(id)
		);	
	
	 设置属性值的自动增加：
	 	 create table table_name 
		（
		ID int(11) primary key auto_increment,
		name varchar(25) unique,
		deptid int(11),
		salary float，
		constranit fk_emp_dept1 foreign key(deptid) references tb_dept1(id)
		);	
	 
	 
	 查看数据表结构：
	 describe table_name;
	 desc table_name;
	 
	 查看建表语句：
	 show create table table_name\G
	  修改表名：
	  alter table table1 rename to table2;
	  修改字段的数据类型：
	  alter table tb_dept1 modify name varchar2(30);
	  修改字段名：
	  alter table table_name change 旧字段名 新字段名 新数据类型；
	  添加字段：
	  alter table table_name add 新字段名 数据类型；
	  删除字段：
	  alter table table_name drop 字段名;
	  
	  更改表的存储引擎：
	  alter table table_name engine=更改后的存储引擎名;
	  删除表的外键：
	  alter table  table_name drop foreign key 外键约束名;
	  删除没有被关联的表：
	  drop table [if exists] 表1,表2,...表n;	  
	  删除有关联的表，先删除子表后删除父表。如果保存子表，可先取消外键约束后删除父表。
	  删除被数据表tb_emp管理的数据表tb_dept2:
	  alter table tb_emp drop foreign key fk_emp_dept；
	  drop table tb_dept2;
	  
	  注意：
	  表删除操作将把表的定义和表中的数据一起删除，不会有任何的确认信息提示，因此执行删除操作时先备份表。
	  
	 
索引的基本操作：
	  最基本的索引类型，没有唯一性之类的限制，其作用只是加快对数据的访问速度。
	  
	  在已经存在的表上创建索引：
	  alter table table_name add [unique|fulltext|spatial] [index|key]
	  index_name (col_name[length])[ASC|DESC];
	  
	  查看已创建的索引：
	  show index from table_name\G
	  字段解释：
	  1.table:表示创建索引的表。
	  2.non_unique：表示索引是否唯一，1代表是非唯一索引，0代表唯一索引。
	  3.key_name表示索引的名称。
	  4.seq_in_index表示该字段在索引中的位置，单列索引该值为1，组合索引为每个字段在索引定义中的顺序。
	  5.column_name表示定义索引的列字段
	  6.sub_part表示索引的长度
	  7.null表示该字段是否能为空值
	  8.index_type表示索引类型
	  
	  删除索引：
	  alter table table_name drop index index_name;
	  
视图
		视图是一个虚拟表，是从数据库中一个或多个表中导出来的表。视图还可以从已经存在的视图的基础上定义。
		视图的作用：
			 1.简单化
			 2.安全性
			 3.逻辑数据独立性
		创建视图：
		create view view_name as select statement from table_name where ...;
		查看视图：
		desc view_name;
		 查看视图基本信息：
		 show table status like 'VIEW_NAME';
		 views表中查看视图详细信息：
		 select * from information_schema.views;
		 查看view的创建语句：
		 show create view view_name\G 
MySQL用户管理：
	 权限表
		user表是一个权限表，记录允许连接到服务器的账号信息，里面的权限是全局级的。、
		user表有42个字段，分别是用户列（host,user,password）、权限列、安全列和资源控制列。
		db表和host表是mysql数据库中非常重要的权限表。
		db表中存储了用户对某个数据库的操作权限，决定用户能从哪个主机存取哪个数据库
	 
数据库备份与恢复

MySQL日志

性能优化

mysql replication

	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 









	 