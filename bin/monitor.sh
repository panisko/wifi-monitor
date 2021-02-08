#!/bin/bash 
#setup tcpdump
#https://askubuntu.com/questions/530920/tcpdump-permissions-problem
CWD=$HOME
monOn=$( ifconfig mon0 | wc -l )
command=$1

stop(){
if [[ -f $CWD/tmp/save_pid.txt ]]
	then
		kill $(ps -o pid= --ppid $(cat $CWD/tmp/save_pid.txt)) 2>/dev/null
		rm $CWD/tmp/save_pid.txt
		rm $CWD/tmp/script.sh
	else
		echo "PID file does not exist, application is stopped"
fi

}

start(){
#setup

if [[ -f $CWD/tmp/save_pid.txt ]]
	then
		echo "application already started, nothing to do"
		exit 1
fi
if [[ monOn -eq 0 ]]
	then
		echo "Interface not ready, making it ready" 
		sudo iw phy phy1 interface add mon0 type monitor
		sudo iw dev wlan1 del
		sudo ifconfig mon0 up
fi
#exec
#read known macs

IFS=$'\n' read -d '' -r -a lines < $CWD/etc/mac.monitor
options=''
pre=' | grep -v '
suf=''
sep=''
for line in "${lines[@]}"
	do
	options="${options} ${pre}${line}${suf}"
done
cmd="/usr/sbin/tcpdump -i mon0 -e -s 256 \"type mgt subtype beacon\" ${options}"
echo ${cmd} > $CWD/tmp/script.sh

#nohup sh ../tmp/script.sh  >> ../log/tcpdump.response 2>&1 &
nohup sh $CWD/tmp/script.sh  >> $CWD/log/tcpdump.response 2>/dev/null &
echo $! > $CWD/tmp/save_pid.txt
}


if [[ $command == "start" ]]
	then
		start
fi
if [[ $command == "stop" ]]
	then
		stop
fi

if [[ $command == "restart" ]]
	then
		stop
		sleep 1
		start
fi


