NAME = inception
DOCKER_COMPOSE = ./srcs/docker-compose.yml
DATA_PATH = ndehmej

all: up

up: setup
	docker compose -f $(DOCKER_COMPOSE) up -d --build

down:
	docker compose -f $(DOCKER_COMPOSE) down

setup:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

clean: down
	docker system prune -af

fclean: clean
	@docker run --rm -v $(DATA_PATH):/clean alpine rm -rf /clean/mariadb /clean/wordpress
	@rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all up down setup clean fclean re