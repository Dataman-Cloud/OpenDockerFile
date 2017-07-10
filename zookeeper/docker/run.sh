docker rm -f dataman-zookeeper && \
service=dataman-zookeeper && \
MASTER_LIST=10.3.10.33 && \
ENNAME=eth0 && \
ZKLIST="$(echo $MASTER_LIST | sed "s/,/ /g" | sed "s/ /:2888:3888,/g"):2888:3888" && \
docker run -it \
       -e ZKLIST="$ZKLIST" \
       -e ENNAME="$ENNAME" \
       --name $service --net host --restart always \
       --net host \
       library/centos7-zookeeper-3.4.6
#--entrypoint=bash \
       #-e ZOO_LOG_DIR=/data/logs/ \
       #-e ZOO_LOG4J_PROP=INFO,CONSOLE \
       #-e JAVA_OPTS="-Xmx512M -Xms256M"  \
