#!/bin/bash
#date:20190628
#author:meiguiwei
#description:ifDemo
read -p "pls input two num:" a b
if [ $a -lt $b ]
then 
	echo "yes,$a less than $b"
	exit 0
fi

if [ $a -gt $b ]
then
	echo "yes $a greater than $b"
	exit 0
fi

if [ $a -eq $b ]
then
	echo "yes $a equal $b"
	exit 0
fi

#demo2
#incomingParameter
a=$1
b=$2
if [ $a -lt $b ]
then 
	echo "yes,$a less than $b"
	exit 0
fi

if [ $a -gt $b ]
then
	echo "yes $a greater than $b"
	exit 0
fi

if [ $a -eq $b ]
then
	echo "yes $a equal $b"
	exit 0
fi


#brachDemo
a=$1
b=$2
if [ $a -lt $b ]
then 
	echo "yes,$a less than $b"
	exit 0
elif [ $a -gt $b ]
then
	echo "yes $a greater than $b"
	exit 0
else [ $a -eq $b ]
	echo "yes $a equal $b"
	exit 0
fi
