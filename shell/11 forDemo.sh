#!/bin/bash
#date:20190717
#author:meiguiwei
#description:forDemo
#changeFileName
cd /daniel
for file in `ls *.log` 
do
	mv $file `echo $file|sed 's/_finish//g'`
done
------------------
#recoverFileName.sh
ls |awk -F "." '{print "mv",$0,$1"_finished".$2}'|bash
-------------
rename "_finished" "" *.jpg
-----------------
批量去掉测试数据所用的bd字符：bd501.html
rename "bd" "" *.html
501.html
---------------------
查看三级别上开启的服务：
chkconfig --list|grep 3:on
-------------------------------------------
#关闭默认开启的三级服务，添加其他服务到启动项中
LANG=en
for serviceName in 	`chkconfig --list|grep 3:on|awk '{print $1}'`
do
	chkconfig --level 3 $serviceName off
done
for serviceName in crond network rsyslog sshd sysstat
do
	chkconfig --level 3 $serviceName on
done
chkconfig --list|grep 3:on >/tmp/chkconfig_on.log
-------------------------------------------
#mysql批量创建数据库脚本
PATH="/applicatin/mysql/bin:$PATH"
MYUSER=root
MYPASS=oldboy123
SOCKET=/data/3306/mysql.dock
MYCMD="mysql -u$MYUSER -p$MYPASS -S $SOCKET"
for dbname in daniel machiel math
do
	$MYCMD -e "create database $dbname"
done

#分库备份数据库
PATH="/applicatin/mysql/bin:$PATH"
MYUSER=root
DBPATH=/data/databackup
MYPASS=oldboy123
SOCKET=/data/3306/mysql.dock
MYCMD="mysql -u$MYUSER -p$MYPASS -S $SOCKET"
MYDUMP="mysqldump -u$MYUSER -p$MYPASS -S $SOCKET"
[ ! -d "$PATH" ] && mkdir $DBPATH
for dbname in `$MYCMD -e "show databases;"|sed '1,2d'|egrep -v "mysql|schema"`
do
	$MYDUMP $dbname|gzip >$DBPATH/${dbname}_$(date +%F).sql.gz
done
----------------------------------------------
#通过脚本批量建表并插入数据
PATH="/applicatin/mysql/bin:$PATH"
MYUSER=root
DBPATH=/data/databackup
MYPASS=oldboy123
SOCKET=/data/3306/mysql.dock
for dbname in daniel machiel math
do
	$MYCMD -e "use $dbname;create tabel test(id int,name varchar(16));insert into test values(1,'testdata');commit; "
done
#querytable
for dbname in daniel machiel math
do
	echo ===========${dbname}.tet===============
	$MYSCMD -e "use $name;select * from ${dbname}.test;"
done


--------------------------------------------------------------------
#真正的解决答案(两层循环)
#!/bin/bash
PATH="/applicatin/mysql/bin:$PATH"
MYUSER=root
DBPATH=/data/databackup
MYPASS=oldboy123
SOCKET=/data/3306/mysql.dock
MYCMD="mysql -u$MYUSER -p$MYPASS -S $SOCEKT"
MYDUMP="mysqldump -u$MYUSER -p$MYPASS -S $SOCKET"
[ ! -d $DBPATH ] && mkdir $DBPATH
for dbname in `$MYCMD -e "show databases;"|sed '1,2d'|egrep -v "mysql|schema"`
do
	mkdir $DBPATH/${dbname}_$(date +%F) -p
	for table in `$MYMD -e "show tables from $dbname"|sed '1d'`
	do
		$MYDUMP $dbname $table|gzip >$DBPATH/${dbname}_$(date +%F)/${dbname}_${table}.sql.gz
	done
done
-----------------------------------------------------------------------
#例子：11-13

