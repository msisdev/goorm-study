# docker-nginx

[Docker Nginx](https://hub.docker.com/_/nginx)

## Build
```
cd spring-service
gradle bootBuildImage
```

## Run
With Nginx
- `docker compose -f docker-compose.yaml up`
- `curl http://localhost:8080/api/greeting`
- `curl http://localhost:8080/api/users -d name=First -d email=someemail@someemailprovider.com`
- `curl http://localhost:8080/api/users`


Without Ningx
- `docker compose -f docker-compose-basic.yaml up`
- `curl http://localhost:8080/api/greeting`
- `curl http://localhost:8081/api/users -d name=First -d email=someemail@someemailprovider.com`
- `curl http://localhost:8081/api/users`
