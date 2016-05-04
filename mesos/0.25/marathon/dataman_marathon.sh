#!/bin/bash
java -Djava.library.path=/usr/local/lib:/usr/lib:/usr/lib64 -Djava.util.logging.SimpleFormatter.format=%2$s%5$s%6$s%n $JAVA_OPTS -cp /usr/bin/marathon mesosphere.marathon.Main --hostname $MARATHON_HOSTNAME --event_subscriber $SUBSCRIBER --master $MESOS_ZK --zk $MARATHON_ZK --http_port $MARATHON_PORT
