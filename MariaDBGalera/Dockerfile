FROM mariadb:10.1.14

MAINTAINER weitao zhou <wtzhou@dataman-inc.com>

ENV WSREP_CLUSTER_ADDRESS ""
COPY my.cnf /etc/mysql/my.cnf
COPY galera-entrypoint.sh galera-entrypoint.sh
RUN chmod 755 galera-entrypoint.sh

EXPOSE 3306 4567 4568 4444

ENTRYPOINT ["/galera-entrypoint.sh"]
