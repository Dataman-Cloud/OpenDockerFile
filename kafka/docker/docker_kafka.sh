#docker run -d \
docker run -it --entrypoint=/bin/bash \
        -e NUM_PARTITIONS=1 \
        -e KAFKA_LOG=/data/log/kafka \
        -e KAFKA_ZOOKEEPER_CONNECT=10.3.10.52:2181 \
        -e KAFKA_PORT=9092 \
        -e JMX_PORT=19092 \
	-e KAFKA_HEAP_OPTS="-Xmx2G -Xms2G" \
        --name kafka  --net host \
	-v /data/tools/kafka:/data/tools/kafka \
	10.3.10.33:5000/centos7/jdk7-scala2.11-kafka0.8.22:2015101501	
