#!/bin/bash

docker-entrypoint.sh mysqld --wsrep_cluster_address=gcomm://${WSREP_CLUSTER_ADDRESS}
