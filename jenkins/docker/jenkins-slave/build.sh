#!/bin/bash
set -x
#opts='--no-cache'
docker build $opts -t library/centos7-jdk8-jenkins-slave-base .
