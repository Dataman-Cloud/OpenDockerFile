#!/bin/bash
set -x
# Get the last Host IP octet
HOST=$(ip addr show eth0 | grep inet.*brd.*eth0 | awk '{print $2}'| awk -F '/' '{print $1}')

# Create unique broker.id as combination of last octet and the given Marathon Docker porBROKER_ID="${ip4}${PORT0}"
BROKER_ID=$(ip addr show eth0 | grep inet.*brd.*eth0 | awk '{print $2}'| awk -F '/' '{print $1}' | awk -F '.' '{print $4}')

echo $BROKER_ID
# change server.properties config file
cd $KAFKA_HOME/config/ && \
cp dataman.properties.template dataman.properties && \
sed -i 's#\-\-BROKER_ID\-\-#'${BROKER_ID}'#g' dataman.properties && \
sed -i 's#\-\-HOST\-\-#'${HOST}'#g' dataman.properties && \
sed -i 's#\-\-KAFKA_PORT\-\-#'${KAFKA_PORT:-"9092"}'#g' dataman.properties && \
sed -i 's#\-\-KAFKA_LOG\-\-#'${KAFKA_LOG:-"/data/log/kafka"}'#g' dataman.properties && \
sed -i 's#\-\-KAFKA_ZOOKEEPER_CONNECT\-\-#'${KAFKA_ZOOKEEPER_CONNECT:-"localhost:2181"}'#g' dataman.properties && \
sed -i 's#\-\-NUM_PARTITIONS\-\-#'${NUM_PARTITIONS:-"10"}'#g' dataman.properties && \
export JMX_PORT="${JMX_PORT}"

#run kafka broker
if [ $? -eq 0 ];then
	$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/dataman.properties
fi
