#!/bin/bash
#Author:Meiguiwei
#Date:20190625
#Description:ReadDemo
read -t 15 -p "Please input two number:" a b
#no1
[ ${#a} -le 0 ] && {
	echo "The first num is null"
	exit 1
}
[ ${#b} -le 0 ] && {
	echo "The second num is null"
	exit1
}

#no2
expr $a + 1 &>/dev/null
RETAVAL_A=$?
expr $b + 1 &>/dev/null
RETAVAL_B=$?
if [[ $RETAVAL_A -ne 0 -o $RETAVAL_B -ne 0 ]]; then
	echo "one of the num is not num,pls input again"
	exit 1
fi

#no3
echo "a-b=$(($a-$b))"
echo "a+b=$(($a+$b))"
echo "a*b=$(($a*$b))"
echo "a/b=$(($a/$b))"
echo "a**b=$(($a**$b))"
echo "a/b=$(($a/$b))"