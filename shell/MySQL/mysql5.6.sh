#mysql5.6
chapter1

读取配置文件的顺序：
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf
启动过程中指定固定配置文件，使用--default-file
关闭数据库：
cd /mysql57/bin
./mysqladmin -uroot -p shutdown

查看数据库名称：


冷备
热备：
——————————————————

逻辑备份：
mysqldump
--------------
./bin/mysqldump -help

备份全库：
mysqldump --single_transaction --set-gtid-purged=OFF -uroot -p -A >all_20170918.sql

恢复全库：
mysqldump -uroot -p <all_20170918.sql

备份单个数据库：
mysqldump --single_transaction --set-gtid-purged -uroot -p db1 >db1_2019.sql

恢复单个数据库：
mysqldump -uroot -p db1 < db1_2019.sql (如果db1存在，则直接恢复，如果不存在，需要在恢复前，先去数据库中创建一个db1.)

备份单个库单张表的表结构
mysqldump --single-transactin -uroot -p db1 t -d >t.sql

备份单个库单张表的表数据
mysqldump --single-transactin -uroot -p db1 t - >t.sql

-----------------------------------
select ...into outfile; 恢复速度比较快

语法：
备份语法：
select col1,col2 form table_name into outfile '/path/备份文件名称'。

恢复语法：
load data infile '/path/备份文件名称' into table tabal_name;
-------------------------------------------
mydumper（多线程的备份工具，备份速度远远高于mysqldump.备份方式属于逻辑备份）
裸文件备份：
xtrabackup

安装mydumper/myloader.备份及恢复工具。





————————————————————————————————
xtrabackup
全量备份：
增量备份：
