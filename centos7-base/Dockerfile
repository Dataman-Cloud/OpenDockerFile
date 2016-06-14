FROM centos:centos7
MAINTAINER jyliu jyliu@dataman-inc.com

# modify localtime
RUN yum install -y iproute && yum clean all

RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# add filedownload script
ADD https://raw.githubusercontent.com/Dataman-Cloud/OpenDockerFile/master/basefile/scripts/DM_DOCKER_URI_2.7.py /DM_DOCKER_URI.py
ADD https://raw.githubusercontent.com/Dataman-Cloud/OpenDockerFile/master/basefile/scripts/filedownload.sh /filedownload.sh
RUN chmod +x /*.py /*.sh
