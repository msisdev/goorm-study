#!/bin/bash

docker swarm init

docker network create -d overlay my-net

docker service create\
  --name mysql-service\
  --network my-net\
  -p 3306:3306\
  -e MYSQL_DATABASE=mydatabase\
  -e MYSQL_PASSWORD=secret\
  -e MYSQL_ROOT_PASSWORD=verysecret\
  -e MYSQL_USER=myuser\
  mysql

docker service create\
  --name spring-app\
  --network my-net\
  -p 8080:8080\
  -e SERVER_PORT=8080\
  -e SPRING_DATASOURCE_URL=jdbc:mysql://mysql-service:3306/mydatabase\
  -e SPRING_DATASOURCE_USERNAME=myuser\
  -e SPRING_DATASOURCE_PASSWORD=secret\
  docker.io/library/accessing-data-mysql:0.0.1-SNAPSHOT

