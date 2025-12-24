NAME = inception
DOCKER_COMPOSE = ./srcs/docker-compose.yml
DATA_PATH = /home/rems/data

all: up

# Crée les dossiers de volume sur l'hôte avant de lancer Docker
setup:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

# Lance le build et les conteneurs
up: setup
	docker compose -f $(DOCKER_COMPOSE) up -d --build

# Arrête les conteneurs
down:
	docker compose -f $(DOCKER_COMPOSE) down

# Affiche les logs en temps réel (pratique pour debug)
logs:
	docker compose -f $(DOCKER_COMPOSE) logs -f

# Nettoie les conteneurs et images inutilisées
clean: down
	docker system prune -af

# Nettoyage TOTAL (Volumes + Fichiers Hôte)
# C'est ici que la magie opère pour contourner "Permission Denied"
fclean: clean_data clean
	docker compose -f $(DOCKER_COMPOSE) down -v
	@docker run --rm -v $(DATA_PATH):/clean alpine sh -c "rm -rf /clean/*" || true
	@rm -rf $(DATA_PATH)

clean_data:
	@docker run --rm -v /home/rems/data/mariadb:/clean alpine sh -c "rm -rf /clean/*"
	@docker run --rm -v /home/rems/data/wordpress:/clean alpine sh -c "rm -rf /clean/*"

re: clean_data fclean all

.PHONY: all up down setup logs clean fclean re
