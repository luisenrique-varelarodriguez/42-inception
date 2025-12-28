# ==============================================
# INCEPTION PROJECT - MAKEFILE
# ==============================================

COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_DIR = $(HOME)/data
SSL_DIR = ./srcs/ssl

.PHONY: all up down stop restart clean fclean destroy logs ps

all: up

up:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress $(DATA_DIR)/portainer
	@docker compose -f $(COMPOSE_FILE) up -d --build

down:
	@docker compose -f $(COMPOSE_FILE) down

stop:
	@docker compose -f $(COMPOSE_FILE) stop

restart:
	@docker compose -f $(COMPOSE_FILE) restart

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

ps:
	@docker compose -f $(COMPOSE_FILE) ps

clean: down
	@rm -rf $(DATA_DIR)/mariadb/* $(DATA_DIR)/wordpress/* $(DATA_DIR)/portainer/*

fclean: down
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all
	@rm -rf $(DATA_DIR)
	@rm -f $(SSL_DIR)/*.crt $(SSL_DIR)/*.key
	@echo "✅ Cleaned: containers, images, volumes, data, and SSL certificates"

destroy:
	@echo "⚠️  Removing ALL Docker resources in 3 seconds..."
	@sleep 3
	-@docker stop $$(docker ps -qa) 2>/dev/null || true
	-@docker rm $$(docker ps -qa) 2>/dev/null || true
	-@docker rmi -f $$(docker images -qa) 2>/dev/null || true
	-@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	-@docker network rm $$(docker network ls -q) 2>/dev/null || true
	@rm -rf $(DATA_DIR)
	@echo "✅ All Docker resources have been removed."