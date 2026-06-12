all:
	mkdir -p /home/myda-chi/data/html /home/myda-chi/data/mariadb
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

re:
	docker compose -f srcs/docker-compose.yml up --build --force-recreate

clean:
	docker compose -f srcs/docker-compose.yml down -v
	sudo rm -rf /home/myda-chi/data/html/*
	sudo rm -rf /home/myda-chi/data/mariadb/*

fclean: clean
	docker system prune -af
	sudo rm -rf /home/myda-chi/data/*
	sudo rm -rf /home/myda-chi/data/.* 2>/dev/null || true

.PHONY: all down re clean fclean