all : up

# Start the Docker Compose services
up : 
	docker-compose -f ./srcs/docker-compose.yml up -d --build

# Down the Docker Compose services
down : 
	docker-compose -f ./srcs/docker-compose.yml down

# Stop the Docker Compose services
stop : 
	docker-compose -f ./srcs/docker-compose.yml stop

# Restart the Docker Compose services
restart : 
	docker-compose -f ./srcs/docker-compose.yml restart

# Destroy the Docker Compose services
destroy:
	-docker stop $$(docker ps -qa);
	-docker rm $$(docker ps -qa);
	-docker rmi -f $$(docker images -qa);
	-docker volume rm $$(docker volume ls -q);
	-docker network rm $$(docker network ls -q) 2>/dev/null;

.PHONY: all up down stop restart destroy