#!/usr/bin/bash

DEF_COLOR="\033[0;39m"
BOLD="\033[1;39m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"

ProgressBar ()
{
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
	printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%% "
}

exec_set ()
{
	ProgressBar 0 $1
	for i in $(eval echo "{1..$1}")
	do
		$(< 10k.txt shuf | head -n $2 > testcase.txt)
		ARG=$(< testcase.txt)
		../push_swap $ARG | ./checker_linux $ARG &> status.txt
		if cat status.txt | grep OK > /dev/null; then
			ProgressBar $i $1
			../push_swap $ARG | wc -l >> count.txt
		elif cat status.txt | grep Error > /dev/null; then
			printf "\nStatus : ${RED}Error${DEF_COLOR}\n"
			printf "Testcase saved in file KO_testcase.txt\n"
			cp testcase.txt KO_testcase.txt
			return 0
		else
			printf "\nStatus : ${RED}KO${DEF_COLOR}\n"
			printf "Testcase saved in file KO_testcase.txt\n"
			cp testcase.txt KO_testcase.txt
			return 0
		fi
	done
		total=$(awk '{ sum += $1 } END { print sum }' count.txt)
		lines=$(cat count.txt | wc -l)
		average=$((total / lines))
		printf "\nStatus : ${GREEN}OK${DEF_COLOR} Average: $average\n"
		rm -f count.txt
	return 1
}

exec_all ()
{
	for i in $(eval echo "{$1..$2}")
	do
		printf "${BOLD}===Test===${DEF_COLOR}\n"
		printf "Stacksize: $i Cases: $3\n"
		if exec_set $3 $i; then
			return 0
		fi
		printf "\n"
	done
}

exec_all $1 $2 $3

rm -f testcase.txt
rm -f status.txt
