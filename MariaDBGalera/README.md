MariaDB Galera
==============

## How to use it

1. build the docker image

   ```bash
   docker build -t mariadb-galera:10.1.14 .
   ```

2. start the first node at nodeA

   ```bash
   docker run -p 3306:3306 -p 4567:4567 -p 4568:4568 -p 4444:4444  -v /data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password --restart=always --name=master_db -d mariadb-galera:10.1.14
   ```

3. start the second, third nodes at the related nodes

   ```bash
   docker run -p 3306:3306 -p 4567:4567 -p 4568:4568 -p 4444:4444  -v /data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e WSREP_CLUSTER_ADDRESS=IP.nodeA --name=joiner_db --restart=always -d mariadb-galera:10.1.14
   ```

4. check the cluster status

  You can get the cluster status info by the following cmds:

  ```bash
  docker exec -it joiner_db bash
  mysql -uroot -ppassword -e "SHOW STATUS LIKE 'wsrep_%';"
  ```

## Issues

1. In my servers, the 2nd, 3rd etc. nodes failed to start&join the cluster always when I run the container joiner. To make it, I have to restart the exited container once more. So here I am setting `--restart=always` .
