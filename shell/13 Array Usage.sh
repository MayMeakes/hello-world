#!/bin/bash
#name:array	
#date：20191122

#commonGrammar

#fristWay
array=(value1 value2 value3)
echo ${array[1]}
echo ${array[*]} #print all variables value


#sencondWay dont't recommend use
array=([1]=one [2]=tow [3]=three)

#thirdWay don't recommend use
#Print array elements

#1.1The sample is as follows
array=(one two three0)
echo ${array[0]}
echo ${array[1]}
echo ${array[2]}
echo ${array[*]}

#1.2Print the number of array elements
#You get the entire array

#Gets the length of the array
echo ${#array[*]}

#follow expression is same
echo ${array[*]}
echo ${array[@]}

#1.3Assign values to arrays
#The sample is as follow
array=(one two three)
echo ${array[1]}
array[3]=four
echo ${array[@]}

array[0]=oldboy
echo ${array[*]}

#1.4Array deletion
echo ${array[*]}
unset array[0] #Cancels array elements with index one.
echo ${array[@]}
unset array #Delete the entire array

#1.5 Interception and replacement of array contents
array=(1 2 3 4 5)
echo ${array[@]:1:3} #Take an array from one to three
array=($(echo {a..z})) #Assign the result of the variable to array
echo ${array[@]}


array=(1 1 1 1 3 2 3)
echo ${array[@]/1/b} #Replace one in the array with b

array=(one two three four five)
echo ${array[@]#o*}

#2.1Development practice about array script

#example_01"
#!/bin/bash"
array=(1 2 3 4 5)
for i in ${array[@]}
do
	echo $i
done

#example_02
#!/bin/bash
array=(
	oldboy
	oldgiral
	xiaoting
	bingg
	)
for ((i=0;i<${#array[@]};i++))
do
	echo "This is num $i, then content is ${array[$i]}"
done
echo -------------------------------
echo "array len:${#array[]}"


#example 3
#!/bin/bash
dir=($(ls -l /array))
for ((i=0;i<${#array[@]};i++))
do
	echo "This is NO.$i,filename is ${array[$i]}"
done



#3.important commands of array

#3.1 Define the command
#static array
array=(1 2 3 4 5)
#dynamic array
array=($(ls))
#assign value to array
array[4]=four
#3.2 print command for array
#print all elements of array
echo ${array[@]}
echo ${array[*]}

#print length of array
echo ${#array[@]}
#print single elements of array
echo ${array[$i]}


#3.3 Common basic syntax for circular printing
#!/bin/bash
arr=(
	10.0.0.11
	10.0.0.12
	10.0.0.14
	10.0.0.13
	)

for ((i;i<${#array[@]};i++))
do
	echo "${arra[$i]}"
done

#4.1 pracitce shell scripts in interview and company
#Print words with more than six letters

#way1
#!/bin/bash
array=(I am oldboy teacher welcome oldboy training lessons)
for (( i = 0; i < ${#array[@]}; i++ )); do
	if [ ${#array[$i]} -gt 6 ]; then
		echo "${array[$i]}"
	fi
done

echo ------------------

for word in ${array[@]}; do
	if [[ `expr length $word` -ge 6 ]]; then
		echo $word
	fi
done



#way2
#!/bin/bash

for word in I am oldboy teacher welcome to oldboy training class
do
	if [[ `echo $word|wc -l` -ge 6 ]]; then
		echo $word
	fi
done


#way3 by use awk
#!/bin/bash
chars="I am oldboyteacher welcome to oldboy training class"
echo $chars|awk '{for(i=1;i<=NF;i++) if(length($i)<=6) print $i}'



#example2 Batch check multiple urls, whether normal
#!/bin/bash
. /etc/init.d/functions
check_count=0
url_list=(
	http://blog.baidu.commandh
	http://blog.etaiadfa.org
	http://10.0.0.7
	)
function wait(){
	echo -n 'Perform the check url operation in three seconds'
	for (( i = 0; i < 3; i++ )); do
		echo -n ".",sleep 1
	done
	echo
}

function check_url(){
	wait
for (( i = 0; i < `echo ${#url_list[@]}`; i++ )); do
		wget -o /dev/null -T 3 --tries=1 --spider ${url_list[$i]} >/dev/null 2>&1
		if [[ $? -eq 0 ]]; then
			action "${url_list[$i]}" /bin/true
		else
			action "${url_list[$i]}" /bin/false
		fi
	done
	((check_count++))
}

main(){
	while true
	do
		check_url
		echo "---------check count:${check_count}----------"
		sleep 10
	done
}
main


#example3 monitorStautsOfMySQLreplication

#!/bin/bash
######################################################
#this script functon is
#check_mysql_slave_replication_status
#USER:
#Date:
######################################################
path=/server/scripts
MAILL_GROUP='dfdsf@ebay.com dfadf@ebay.com'
PAGER_GROUP='134340912 123123'
LOG_FILE="/tmp/we_check.log"
USER=root
PASSWORD=dsfasdfas
PORT=3036
MYSQLCMD="mysql -u$USER -p$PASSWORD -S /data/$PORT/mysql.sock"

error=(1008 1007 1062)
RETVAL=0
[ ! -d "$path" ] && mkdir -p $path
function JugeError(){
	for (( i = 0; i < ${#error[@]}; i++ )); do
		if [[ "$1" == "${error[$i]}" ]]; then
			echo "MySQL slave errorno is $1,auto repairing it."
			$MYSQLCMD -e "stop slave,set global sql_slave_skip_counter=1;start slave;"
		fi
	done
	return $1
}

function CheckDB(){
	status=($(awk -F ':' '/_Runing|Last_Errno|_Behind/{print $NF}' slave.log))
	expr ${status[3]} + 1 &>/dev/null
	if [[ $? -ne 0 ]]; then
		status[3]=300
	fi
	if [[ "${status[0]}" == "Yes" -a "${status[1]}" == "Yes" -a ${status[3]} -lt 120 ]]; then
		return 0
	else
		JudgeError ${status[2]}
	fi
}

function MAIL() {
	local SUBJECT_CONTENT=$1
	for MAIL_USER in `echo $MAIL_GROUP`
	do
		mail -s "$SUBJECT_CONTENT" $MAIL_USER <$LOG_FILE
	done
}

function PAGER(){
	for PAGER_USER in `echo $PAGER_GROUP`; do
		TITLE=$1
		CONTACT=$PAGER_USER
		HTTPW=http://dfdsf.sms.cn/smsproxy/sendsms.action
		curl -d cdkey=5ADF_EFF -d pasword=dsfdsf -d phone=$CONTACT message="$TITLE[$@]" $HTTPW		
	done
}


function SendMsg(){
	if [[ $1 -ne 0 ]]; then
		RETVAL=1
		NOW_TIME=`date +"%Y-%m-%d %H:%M:%S"`
		SUBJECT_CONTENT="mysql slave is error,errorno is $2,${NOW_TIME}"
		echo -e "SUBJECT_CONTENT"|tee $LOG_FILE
		MAIL $SUBJECT_CONTENT
		PAGER $SUBJECT_CONTENT
	else
		echo "Mysql slave status is ok"
	fi
	return $RETVAL
}

function main(){
	while true
	do
		CheckDB
		SendMsg
		sleep 30
	done

}
main































