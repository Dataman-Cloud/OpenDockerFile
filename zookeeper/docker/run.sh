service=dataman-zookeeper

                    docker run -d \
                            -e ZOO_LOG_DIR=/data/logs/ \
                            -e ZOO_LOG4J_PROP=INFO,CONSOLE \
                            -e JAVA_OPTS="-Xmx512M -Xms256M"  \
                            --name $service --net host --restart always \
                            centos7/zookeeper-3.4.6
                            #centos7/zookeeper-3.5.1
#--entrypoint=bash \
