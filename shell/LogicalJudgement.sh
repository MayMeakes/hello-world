#!/bin/bash
#date:20190625
#LogicalTest

#InputNumber
echo -n "pls input nmuber:"
read A
#LogicJudgement

if [ $A -eq 1 ] || [ $A -eq 2 ]
then
	echo $A
else
	echo "The number you input is wrong."
	exit 1
fi


#Demo2
#InputNumber
read -p "pls input number" var
[ "$var" == 1 ]&&{
	echo 1
	exit 0
}

[ "$var" == 2 ]&&{
	echo 2
	exit 0
}

[ "$var" != 1 -a "$var" != 2 ]&&{
	echo "error"
	exit 1
}


#!/bin/bash
#date:20190625
#Demo3
#IncomingParameter
a=$1
b=$2
#no1
[ $# -ne 2 ] &&{
	echo "USAGE:$0 NUM1 NUM2"
	exit 1
}

#no2
expr $a + 10 &>/dev/null
RETVAL=$?
expr $b + 10 &>/dev/null
RETVAL2=$?
test $RETVAL -eq 0 -a $RETVAL2 -eq 0 ||{
	echo "Pls input two "num" again."
	exit 2
}
#no3
[ $a -lt $b ]&&{
	echo "$a<$b"
	exit 0
}

#no4
[ $a -eq $b ] &&{
	echo "$a=$b"
	exit 0
}

#no5
[ $a -gt $b ] &&{
	echo "$a > $b"
}



s

