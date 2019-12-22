#!/bin/bash
#change max_dump_file_size
instance=`ps -ef | grep pmon | grep -v grep | grep -v ASM | grep pmon | awk '{print $NF}'| awk -F '_' '{print "export ORACLE_SID="$NF}'`
for export_sid in $instance
	do
	 
#change parameter dynamic in oracle DB
sqlplus -s / as sysdba<<EOF 
alter system set max_dump_file_size=100M;
exit; 
EOF` 
echo ''
done 



#!/bin/bash
#change max_dump_file_size
instance=`ps -ef | grep pmon | grep -v grep | grep -v ASM | grep pmon | awk '{print $NF}'|awk -F '_' '{print $3}'`
for instance_name in $instance
	do
export oracle_sid=$instance_name
echo $oracle_sid
#change parameter dynamic in oracle DB
sqlplus -s / as sysdba<<EOF
alter system set MAX_DUMP_FILE_SIZE='100M';
show parameter max_dump_file_size
exit; 
EOF
echo 'parameter max_dump_file_size has been changed'
done