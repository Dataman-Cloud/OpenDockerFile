docker run -d \
                        -e JAVA_OPTS="-Xmx512M -Xms512M" \
                        -e JENKINS_PORT="8002" \
                        --name jenkins  --net host --privileged \
                        testregistry.dataman.io/centos7/mesos-0.23.0-jdk8-jenkins1.628-master
