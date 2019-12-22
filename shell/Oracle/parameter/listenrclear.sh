IP=$1   #SCRIPT EXECUTION OBJECT IP 
OS=$2   #SCRIPT EXECUTION OBJECT. For example Linux/AIX/HP-UX/Windows 
EXECUTE_USER=$3 #SCRIPT EXECUTING USER, such as patrol/jtoper01 
#!/bin/bash 
################################################ 
# version: 1.1                                 # 
# 2019/01/02                                   # 
# config adrci for oracle & grid               # 
################################################ 




ckip=`sqlplus -s autotask_control/"Nac9#nac"@10.190.21.76:21026/dgmon<<EOF 
set heading off feedback off pagesize 0 verify off echo off numwidth 9 
select count(*) from ORA_CXIDS_LIST where IP='$IP'; 
exit; 
EOF` 


if [ $ckip -eq 0 ];then 
   echo "IP is not allowed...[ERROR]" 
   echo "IP not in 10.190.21.76<autotask_control.ORA_CXIDS_LIST>" 
   exit 1 
fi 


echo "IP check...[PASS]" 


echo "#########################" 


echo "oracle version check:" 
sqlplus -v 


ora_version=`sqlplus -v |grep Release |grep -v grep |awk -F '.' '{print $1}'|awk -F ' ' '{print $NF}'` 


if [ $ora_version -eq 10 ];then 
  echo "oracle version :10g  not support command <adrci>" 
  exit 1 
fi 


########################### 


function adrci_clear() 
{ 
adrtmp=$(adrci <<EOF 
show home 
exit 
EOF 
) 


adrchg=${adrtmp##*Homes:} 
adrhome=${adrchg%adrci*} 


for adrno in ${adrhome} 
do 
adrci<<EOF 
set home $adrno 
show control 
set control (SHORTP_POLICY = 360) 
set control (LONGP_POLICY =  720) 
purge 
EOF 
echo "######################################" 
done 


df -P |grep /u01 


usertmp=` ps -ef|grep smon |grep -v grep |grep -v root |grep -v oracle |grep -v grid |awk -F ' ' '{print $1}'` 


if [ $(ps -ef|grep smon |grep -v grep |grep -v root |grep -v oracle |grep -v grid|wc -l) -ne 0 ] ;then 
 echo "Other unknown user exist!!!" 
 echo "username:${usertmp}" 
 exit 1 
fi 
} 


########## 
adrci_clear; 




####################################### 
function listenerlog_clear() 
{ 
lsnr_status=` lsnrctl show log_status|grep log_status|awk -F ' ' '{print $6}' ` 


echo $lsnr_status 


#if   [ $lsnr_status == "OFF" ];then 
#  echo "#########` lsnrctl show log_status|grep log_status `" 
#fi 


lsnr_name=` ps -ef|grep tns|grep -v grep|grep oracle|awk -F ' ' '{print $9}' ` 
for lsnrno in ${lsnr_name} 
 do 
#   echo $lsnrno         
   lsnr_xml=` lsnrctl status $lsnrno|grep Listener|awk -F ' ' '{print $4}'|grep -E xml ` 
   if [ -n "$lsnr_xml" ]; then 
#   echo $lsnr_xml 
       lsnr_log=`cd ${lsnr_xml%/alert*}/trace && ls ` 
#   echo $lsnr_log 
       for i in ${lsnr_log} 
         do   
           cd  ${lsnr_xml%/alert*}/trace 
           echo > $i 
       done     
   else 
      lsnr_log=` lsnrctl status $lsnrno|grep Listener|awk -F ' ' '{print $4}'|grep -E log$ ` 
      echo $lsnr_log 
      echo > $lsnr_log 
  fi 
  
echo "########listener log has been cleared" 
done 


} 
########## 
listenerlog_clear;