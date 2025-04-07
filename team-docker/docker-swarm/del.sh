docker service rm spring-app mysql-service
docker network rm my-net
docker swarm leave --force

echo "Cleanup completed."
