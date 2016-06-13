FROM centos:centos7
MAINTAINER jyliu jyliu@dataman-inc.com

# modify localtime
RUN yum install -y iproute && yum clean all

RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# add filedownload script
COPY DM_DOCKER_URI_2.7.py /DM_DOCKER_URI.py
COPY filedownload.sh /filedownload.sh
RUN chmod +x /*.py /*.sh
