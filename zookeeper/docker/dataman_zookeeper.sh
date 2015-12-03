#!/bin/bash

if [ -z $ZOOCFGDIR ];then
    ZOOCFGDIR="/usr/local/zookeeper/conf"
fi

if [ ! -z "$ZKLIST" ];then
    if [ -z "$ENNAME" ];then
	ENNAME=eth0
    fi
    localip=`ip addr show $ENNAME|grep "inet.*brd.*$ENNAME"|awk '{print $2}'|awk -F/ '{print $1}'`
    zks=""
    i=1
    for server in `echo $ZKLIST|sed 's/\,/ /g'`;do
	zks+="server.$i=$server\n"
	ip=${server%%:*}
	if [ "$ip" == "$localip" ];then
		ZKID=$i
	fi
	let i=$i+1
    done
    echo "$ZKID" > /data/zookeeper/snapshot/myid && \
    sed -i 's/--serverlist--/'$zks'/g' $ZOOCFGDIR/zoo.cfg
else
    sed -i 's/--serverlist--//g' $ZOOCFGDIR/zoo.cfg
fi

if [ $? -eq 0 ];then
    /usr/local/zookeeper/bin/zkServer.sh start-foreground
fi
