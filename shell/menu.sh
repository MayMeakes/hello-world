#!/bin/bash
#date:20190628
#description:menudemo

cat <<END
	1.[install lamp]
	2.[install lnmp]
	3.[exit]
	pls input the num you want:
END

read num
expr $num + 1 &>/dev/null
[ $? -ne 0 ]&&{
	echo "The num you input must be {1|2|3}|"
	exit 1
}

[ $num -eq 1 ]$${
	echo "start installing lamp"
	sleep 2;
	[ -x "$path/lamp.sh" ]||{
		echo "$path/lamp.sh does not exist or can not be exec"
		exit 1
	}
	source $path/lamp.sh
	exit $?
}

[ $num -eq 2 ]&&{
	echo "start installing LNMP."
	sleep 2;
	[ -x "$path/lnmp.sh" ]||{
		echo "$path/lnmp.sh doe not exist or can not be exec"
		exit1
	}
	$path/lnmp.sh
	exit $?
}

[ $num -eq 3 ]&&{
	echo "Bye"
	exit 3
}

[[ ! $num =~ [1-3] ]]&&{
	echo "The num you input must be {1|2|3}"
	echo "Input Error"
	exit 4
}
































#EntertaimentEdition
#Choose
cat <<END
	1.panxiaoting
	2.gongli
	3.liuyifei
END

read -p "Which do you like? please input the num:" a
[ "$a" = "1" ] && {
	echo "I guess,you like panxiaoting"
	exit 0
}

[ "$a" = "2" ] && {
	echo "I guess,you like gongli"
	exit 0
}

[ "$a" = "3" ] && {
	echo "I guess,you like liuyifei"
	exit 0
}

[[ ! "$a" =~ [1-3] ]]&&{
	echo "I guess,you are not man"
}

