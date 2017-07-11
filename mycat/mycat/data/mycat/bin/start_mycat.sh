#!/bin/sh

#replace db info

if [ -z "$MYSQL_IP" -o -z "$MYSQL_PORT" ]; then
    echo "please on docker run command add MYSQL_IP and MYSQL_PORT environment"
    exit -1
fi
sed -i 's/172.16.42.14/'"$MYSQL_IP"'/g' /data/mycat/conf/schema.xml
sed -i 's/3306/'"$MYSQL_PORT"'/g' /data/mycat/conf/schema.xml

#run
CMD="/data/mycat/bin/mycat console"
exec $CMD

