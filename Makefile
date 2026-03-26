NAME        = inception
COMPOSE_DIR = ./srcs
COMPOSE     = docker compose -f $(COMPOSE_DIR)/docker-compose.yml

DATA_DIR    = /home/hugo-mar/data
DB_DIR      = $(DATA_DIR)/mariadb
WP_DIR      = $(DATA_DIR)/wordpress

all: up

up: directories
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	sudo find $(DB_DIR) -mindepth 1 -delete
	sudo find $(WP_DIR) -mindepth 1 -delete

re: fclean up

directories:
	mkdir -p $(DB_DIR)
	mkdir -p $(WP_DIR)

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs

.PHONY: all up down clean fclean re directories ps logs