NAME = inception

all:
	mkdir -p /home/$(USER)/data/mariadb_data
	mkdir -p /home/$(USER)/data/wordpress_data
	docker compose -f srcs/docker-compose.yml up --build

up:
	mkdir -p /home/$(USER)/data/mariadb_data
	mkdir -p /home/$(USER)/data/wordpress_data
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean:
	docker compose -f srcs/docker-compose.yml down -v --rmi all

re: fclean all

.PHONY: all up down clean fclean re
