# /accessing-data-mysql

## Develop

[Guide: Accessing Data MySQL](https://spring.io/guides/gs/accessing-data-mysql)

### Error: Table is not created
Add this line in `src/main/resources/application.properties`
```
spring.jpa.hibernate.ddl-auto=update
```

## Play

Start spring
- `gradle bootRun`

Add new user
- `curl http://localhost:8081/api/users -d name=First -d email=someemail@someemailprovider.com`

Show all users
- `curl http://localhost:8081/api/users`


## Build Image
Edit `application.properties`
```
spring.jpa.hibernate.ddl-auto=update
spring.datasource.url=jdbc:mysql://localhost:3306/mydatabase
spring.datasource.username=myuser
spring.datasource.password=secret
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.show-sql: true
```

Build
- `gradle bootBuildImage`


## Test Image
Run different MySQL container
```yaml
services:
  mysql:
    container_name: 'guide-mysql'
    image: 'mysql:latest'
    environment:
      - 'MYSQL_DATABASE=mydatabase'
      - 'MYSQL_PASSWORD=secret'
      - 'MYSQL_ROOT_PASSWORD=verysecret'
      - 'MYSQL_USER=myuser'
    ports:
      - '3306:3306'
```

Run
- `docker run --network container:guide-mysql docker.io/library/accessing-data-mysql:0.0.1-SNAPSHOT`

Run bastion host
- `docker run --rm --network container:guide-mysql -it alpine`

Install curl
- `apk add curl`

Play
- `curl http://localhost:8081/api/users -d name=First -d email=someemail@someemailprovider.com`
- `curl http://localhost:8081/api/users`

