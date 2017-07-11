#!/bin/sh

#replace db info
#sed -i 's/172.16.42.14/'"$MYSQL_IP"'/g' /data/mycat/conf/schema.xml
#sed -i 's/3306/'"$MYSQL_PORT"'/g' /data/mycat/conf/schema.xml

#run
CMD="/data/mycat/bin/mycat console"
exec $CMD

