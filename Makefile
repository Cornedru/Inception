NAME = inception
DOCKER_COMPOSE = ./srcs/docker-compose.yml
DATA_PATH = /home/rems/data

all: up

setup:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

up: setup
	docker compose -f $(DOCKER_COMPOSE) up -d --build

down:
	docker compose -f $(DOCKER_COMPOSE) down

logs:
	docker compose -f $(DOCKER_COMPOSE) logs -f

clean: down
	docker system prune -af

fclean: clean_data clean
	docker compose -f $(DOCKER_COMPOSE) down -v
	@docker run --rm -v $(DATA_PATH):/clean alpine sh -c "rm -rf /clean/*" || true
	@rm -rf $(DATA_PATH)

clean_data:
	@docker run --rm -v /home/rems/data/mariadb:/clean alpine sh -c "rm -rf /clean/*"
	@docker run --rm -v /home/rems/data/wordpress:/clean alpine sh -c "rm -rf /clean/*"

re: clean_data fclean all

.PHONY: all up down setup logs clean fclean re
