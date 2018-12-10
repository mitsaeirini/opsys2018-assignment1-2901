#!/bin/bash
index=0
text=$1
function1(){
	for element in "${urlsarray[@]}"
	do
		echo "$element INIT" 
	done
	i=0
	while [ $i -lt ${#urlsarray[*]} ]; do
		curmd5sum[$i]=$(wget -q -O- "${urlsarray[$i]}" | md5sum)
		i=$(( $i + 1))
	done
	i=0
	while [ $i -lt ${#urlsarray[*]} ]; do
		status[$i]=0
		i=$(( $i + 1))
	done
	touch file
	i=0
	while [ $i -lt ${#urlsarray[*]} ]; do
		if curl -s --head "${urlsarray[$i]}" > /dev/null; then
			status[$i]=1 
		fi
		echo "${urlsarray[$i]} ${curmd5sum[$i]} ${status[$i]}" >> file
		i=$(( $i + 1))
	done
}
function2(){
	file=./file.txt
	index=0
	while IFS= read -r line in file
	do
		var=($line)
		curmd5sum[$index]=${var[1]}"  "${var[2]}  
		status[$index]=${var[3]}   
		index=$(($index+1))
	done < file
	i=0
	while [ $i -lt ${#urlsarray[*]} ]; do
		newmd5sum[$i]=$(wget -q -O- "${urlsarray[$i]}" | md5sum)
		i=$(( $i + 1))
	done
	i=0
	while [ $i -lt ${#urlsarray[*]} ]; do
		newstatus[$i]=0 
		i=$(( $i + 1))
	done
	i=0
	while [ $i -lt ${#urlsarray[*]} ]; do
		if curl -s --head "${urlsarray[$i]}" > /dev/null; then
			newstatus[$i]=1
		fi
		i=$(( $i + 1))
	done
	> file
	i=0
	while [ $i -lt ${#urlsarray[*]} ]; do
		if [ "${status[$i]}" == 0 -a "${newstatus[$i]}" == 1 ] || [ "${curmd5sum[$i]}" != "${newmd5sum[$i]}" ] 
		then
			echo "${urlsarray[$i]}"
		fi
		if [ "${status[$i]}" == 0 -a "${newstatus[$i]}" == 0 ] 
		then
			echo "${urlsarray[$i]} FAILED"
		fi
		echo "${urlsarray[$i]} ${newmd5sum[$i]} ${newstatus[$i]}" >> file
		i=$(( $i + 1))
	done
}
while IFS= read -r line in $text
do
	if [ ${line:0:1} != "#" ]; then 	 
		urlsarray+=($line)
		if [ ! -e file ]; then
			function1 &
		else
			function2 &
		fi
	fi
	index=$(($index+1))
done < $text