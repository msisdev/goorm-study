# docker-swarm

## Stack
```
docker swarm init
docker stack deploy -c docker-stack.yaml my-stack
docker stack rm my-stack
```

Play
- `curl http://localhost:8080/api/greeting`
- `curl http://localhost:8081/api/users -d name=First -d email=someemail@someemailprovider.com`
- `curl http://localhost:8081/api/users`

(I have not done test because I'm running docker in rootless mode and )

## Other Commands




Swarm
```bash
docker swarm -h
docker swarm init
docker swarm leave --force
```

Overlay network
```bash
docker network ls
docker network create -d overlay my-net
docker network rm my-net
```

MySQL service
```bash
docker service create --name mysql-service --network my-net -e MYSQL_ROOT_PASSWORD=verysecret mysql
docker service rm mysql-service
```

Spring service
```bash
docker service create --name spring-app --network my-net -p 8080:8080 accessing-data-mysql
docker service rm spring-app
```

Inspect
```bash
docker service ls
docker service ps spring-app
```
