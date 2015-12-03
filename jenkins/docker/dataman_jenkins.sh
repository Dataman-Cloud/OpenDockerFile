#!/bin/bash
if [ ! -z  "$DM_READ_URI" ];then
    /data/run/DM_DOCKER_URI.py
    USER=`whoami`
#Jenkins Config bak
    if [ -f /$USER/.ssh/id_rsa ];then
        git config --global user.name $USER && \
        git config --global user.email $USER@$HOST && \
        chmod 400 /$USER/.ssh/id_rsa
        mkdir -p /data/tmp && \
        cd /data/tmp && \
        /data/run/gitclone && \
        mv jenkins-data/* /var/lib/jenkins/
     fi
fi
java ${JAVA_OPTS:-"-Xmx512M -Xms256M"} -jar /usr/lib/jenkins/jenkins.war --httpPort=${JENKINS_PORT:-8001}
