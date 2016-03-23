#create topic
/usr/local/kafka/bin/kafka-topics.sh --zookeeper 10.3.10.52:2181 --create --partitions 3 --replication-factor 3 --topic pztest2
#list topic
/usr/local/kafka/bin/kafka-topics.sh --zookeeper 10.3.10.52:2181 --list
#topic info
/usr/local/kafka/bin/kafka-topics.sh --describe --zookeeper 10.3.10.52:2181 --topic pztest2
#create producer
/usr/local/kafka/bin/kafka-console-producer.sh --broker-list 10.3.10.3:9091,10.3.10.4:9091,10.3.10.5:9091 --topic pztest2
#create consumer
/usr/local/kafka/bin/kafka-console-consumer.sh --zookeeper 10.3.10.52:2181 --from-beginning --topic pztest2
#producer perf test
/usr/local/kafka/bin/kafka-producer-perf-test.sh --messages 500000 --message-size 1000  --batch-size 1000 --topics test1 --threads 4 --broker-list 10.3.10.3:9091,10.3.10.4:9091,10.3.10.5:9091
