#!/bin/sh
#script_name:hot_database_backup.sh
#
# Copyright:
#
MYSQLBACKUP=/usr/local/bin/mysqlbackup
#
My_cnf=/etc/my.cnf
#
MySQL_basedir=/mysql/mysql57
#
Port=16063
#
#
Sock_Name=/mysql/mysql57/mysqld.sock
#
USER=nbu
#
Serect_Code=Q0ZUXjd1am0K
#
PWD=`echo -n $Serect_Code | base64 -d`

#Master Server 
NB_ORA_SERV=MASTERTL4

#MySqlDB Server 
NB_ORA_CLIENT=CXQMYSDB38104

#NetBackup MySQL Database Backup Policy Name
NB_ORA_POLICY=${NB_ORA_CLIENT}_mysql_${Port}_db

#---Check backup_dir_home And Create---#
backup_dir_home=/mysqlbackup/meb_${Port}
if [ ! -d ${backup_dir_home} ]; then
   mkdir -p $backup_dir_home
fi

CMD=/usr/openv/netbackup/bin/bparchive

#
initialize()
{
        CURDATE=`date +%Y%m%d_%H%M%S` 
        dLIB=/usr/openv/netbackup/bin/libobk.so64 
        dBACKUPIMAGENAME=sbt:`hostname`_MEB_Full_${Port}_`/bin/date +%Y%m%d-%H%M%S`
        dOUTLOG=${0}_${CURDATE}.out
        dERRORLOG=${0}_error.log
        dCLEANUP=0
        if [ -f $dOUTLOG ]; then 
        rm -f $dOUTLOG
        fi
        if [ -d $backup_dir_home/$CURDATE ]; then 
        rm -rf $backup_dir_home
        mkdir -p $backup_dir_home 
        else
        mkdir -p $backup_dir_home 
        fi
}


cleanup()
{
        result=$?
        if [[ 0 -ne $result ]]; then 
                echo "Backup failed..."
                rm -rf $backup_dir_home/* 
                exit 1;
        else
                rm -rf $backup_dir_home/* 
                echo "Backup Successful..."
        fi
}
         

do_fullbackup()
{
echo >> $dOUTLOG
echo "----Switch Binlog File at $CURDATE----" >> $dOUTLOG 
${MySQL_basedir}/bin/mysql -S $Sock_Name -u nbu -p''${PWD}'' -e 'flush logs' 2>> $dOUTLOG
echo >> $dOUTLOG
echo "-------------------------------------------" >> $dOUTLOG
echo "  Start Full Backup at $CURDATE   " >> $dOUTLOG 
echo "-------------------------------------------" >> $dOUTLOG
echo >> $dOUTLOG
$MYSQLBACKUP --defaults-file=$My_cnf --port=$Port --protocol=$Protocol --user=$USER --password=$PWD --backup-dir=$backup_dir_home \
--sbt-lib-path=$dLIB --sbt-environment="NB_ORA_SERV=$NB_ORA_SERV,NB_ORA_CLIENT=$NB_ORA_CLIENT,NB_ORA_POLICY=$NB_ORA_POLICY" \
--backup-image=$` backup-to-image 2>> $dOUTLOG 
RETURN_CODE=$?
 if [ $RETURN_CODE -ne 0 ]
  then
        echo "Backup failure status code is $RETURN_CODE" >> $dOUTLOG
        exit $RETURN_CODE
 fi
echo >> $dOUTLOG
echo "-------------------------------------------" >> $dOUTLOG
echo "  End Full Backup at $CURDATE     " >> $dOUTLOG 
echo "-------------------------------------------" >> $dOUTLOG
echo >> $dOUTLOG
}
 



do_conf_backup()
{
$CMD -p $File_Backup $backup_dir_home/*
}


do_validate()
{
echo >> $dOUTLOG
echo "-------------------------------------------" >> $dOUTLOG
echo "  Start Validate at $CURDATE      " >> $dOUTLOG 
echo "-------------------------------------------" >> $dOUTLOG
echo >> $dOUTLOG
$MYSQLBACKUP --backup-image=$dBACKUPIMAGENAME --sbt-lib-path=$dLIB \
--sbt-environment="NB_ORA_SERV=$NB_ORA_SERV,NB_ORA_CLIENT=$NB_ORA_CLIENT,NB_ORA_POLICY=$NB_ORA_POLICY" \
validate 2>> $dOUTLOG 
echo >> $dOUTLOG
echo "-------------------------------------------" >> $dOUTLOG
echo "  End Validate at $CURDATE        " >> $dOUTLOG 
echo "-------------------------------------------" >> $dOUTLOG
echo >> $dOUTLOG cleanup
}


do_incremental_with_redo_log_only()
{
echo >> $dOUTLOG
echo "-------------------------------------------" >> $dOUTLOG
echo "  Start redo log only at $CURDATE " >> $dOUTLOG 
echo "-------------------------------------------" >> $dOUTLOG
echo >> $dOUTLOG
$MYSQLBACKUP --defaults-file=$My_cnf --port=$port --protocol=$Protocol --user=$USER --incremental-with-redo-log-only --incremental-base=history:last_backup \
--sbt-lib-path=$dLIB --sbt-environment="NB_ORA_SERV=$NB_ORA_SERV,NB_ORA_CLIENT=$NB_ORA_CLIENT,NB_ORA_POLICY=$NB_ORA_POLICY" \
--backup-dir=$backup_dir_home --backup-image=sbt:logsbtNB backup-to-image 2>> $dOUTLOG
echo >> $dOUTLOG
echo "-------------------------------------------" >> $dOUTLOG
echo "  End redo log only at $CURDATE   " >> $dOUTLOG 
echo "-------------------------------------------" >> $dOUTLOG
echo >> $dOUTLOG
}


#----Start Call Program Function----#
initialize
cleanup
do_fullbackup

cp -rf $My_cnf /usr/openv/scripts/

/usr/openv/netbackup/bin/bpbackup -p ${NB_ORA_CLIENT}_mysql_${Port}_control -s mysql_userbackup -t 0 $My_cnf

find /usr/openv/scripts -name "*.out" -mtime +15 -exec rm {} \;