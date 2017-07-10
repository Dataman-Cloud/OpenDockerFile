#!/bin/bash

if [ -z $ZOOCFGDIR ];then
    ZOOCFGDIR="/usr/local/zookeeper/conf"
fi

if [ ! -z "$ZKLIST" ];then
    if [ -z "$ENNAME" ];then
	ENNAME=eth0
    fi
    localip=`ip addr show $ENNAME|grep "inet.*scope.*global.*$ENNAME"|awk '{print $2}'|awk -F/ '{print $1}'|head -1`
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
    mkdir -p /data/zookeeper/{snapshot,zklog}

    if [ -z "$ZKID" ];then
    	ZKID=`hostname -s|grep -o '[[:digit:]]*'|tail -1`
    fi

    if [ -z "$ZKID" ];then
	ZKID=`echo $ip|awk '{print $1}'|awk -F. '{print $4}'`
    fi
    echo "$ZKID" > /data/zookeeper/snapshot/myid && \
    sed -i 's/--serverlist--/'$zks'/g' $ZOOCFGDIR/zoo.cfg && \
    sed -i 's/--listen_ip--/'$localip'/g' $ZOOCFGDIR/zoo.cfg
else
    sed -i 's/--serverlist--//g' $ZOOCFGDIR/zoo.cfg && \
    sed -i 's/--listen_ip--//g' $ZOOCFGDIR/zoo.cfg
fi

if [ $? -eq 0 ];then
    /usr/local/zookeeper/bin/zkServer.sh start-foreground
fi
