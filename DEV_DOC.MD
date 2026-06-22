# Developer Documentation

This document describes how to set up, build, and maintain the Inception project from a developer's perspective.

## Prerequisites

- A virtual machine running Debian 12 (Bookworm) — the project must run entirely inside a VM
- Docker Engine installed in the VM
- Docker Compose plugin installed in the VM
- `git` to clone the repository

To install Docker on Debian:
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
sudo apt install -y docker-compose-plugin
```
Log out and back in (or run `newgrp docker`) for the group change to take effect.

## Setting up the environment from scratch

1. Clone the repository:
```bash
git clone -b master https://github.com/myda-chi/inception.git ~/Inception
cd ~/Inception
```

2. Create the required data directories on the host (used by named volumes):
```bash
mkdir -p ~/data/html ~/data/mariadb
```

3. Add the project domain to `/etc/hosts` so it resolves locally:
```bash
echo "127.0.0.1 myda-chi.42.fr" | sudo tee -a /etc/hosts
```

4. Create the configuration file `srcs/.env` with the following variables (replace placeholder values with real ones — never commit this file):
```bash
DOMAIN_NAME=myda-chi.42.fr

# MySQL
MYSQL_DATABASE=wordpress
MYSQL_USER=myda-chi
MYSQL_PASSWORD=your_password
MYSQL_ROOT_PASSWORD=your_root_password

# WordPress
WP_TITLE=Inception
WP_ADMIN_USER=myda-chi_ad
WP_ADMIN_PASSWORD=your_wp_admin_password
WP_ADMIN_EMAIL=myda-chi@student.42.fr
WP_USER=myda-chi
WP_USER_PASSWORD=your_wp_user_password
WP_USER_EMAIL=user@student.42.fr
```

The `.env` file must be excluded from version control via `.gitignore`.

## Building and launching the project

The project is driven by a `Makefile` that wraps Docker Compose commands.

| Command | What it does |
|---------|---------------|
| `make` | Builds all images and starts the containers in the background |
| `make down` | Stops the containers without removing volumes |
| `make re` | Rebuilds images and force-recreates containers |
| `make clean` | Stops containers and removes the associated volumes |
| `make fclean` | Full cleanup: removes containers, volumes, and built images |

Under the hood, these targets call:
```bash
docker compose -f srcs/docker-compose.yml up -d --build
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml down -v
```

## Managing containers and volumes

Useful commands for day-to-day development:

```bash
# List running containers and their status
docker compose -f srcs/docker-compose.yml ps

# Tail logs for all services
docker compose -f srcs/docker-compose.yml logs -f

# Tail logs for a single service
docker compose -f srcs/docker-compose.yml logs -f wordpress

# Open a shell inside a running container
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it nginx bash

# Test the NGINX configuration without restarting
docker exec -it nginx nginx -t

# Connect to the database directly
docker exec -it mariadb mysql -u myda-chi -p

# List existing volumes
docker volume ls

# Inspect a volume's mount point
docker volume inspect srcs_wp-files
```

## Project structure

```
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── docker-compose.yml
    ├── .env                  (not committed)
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/init_wp.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/50-server.cnf
            └── tools/init_db.sh
```

## Where data is stored and how it persists

Two named Docker volumes are declared in `docker-compose.yml`:

```yaml
volumes:
  wp-files:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/myda-chi/data/html

  wp-database:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/myda-chi/data/mariadb
```

- **`wp-files`** is mounted at `/var/www/html` in both the `nginx` and `wordpress` containers. It stores all WordPress core files, themes, plugins, and uploads. Its data lives on the host at `/home/myda-chi/data/html`.
- **`wp-database`** is mounted at `/var/lib/mysql` in the `mariadb` container. It stores all MariaDB database files. Its data lives on the host at `/home/myda-chi/data/mariadb`.

Because these are named volumes pointing at a fixed host path, the data survives `make down` and `make re`. Only `make clean` or `make fclean` (or manually deleting the host folders) will remove the persisted data — after which the next `make` will reinitialize WordPress and the database from scratch.

## Modifying a service's port (e.g. for a defense)

Changing a port generally requires updating the value in **every file that references it**:

- **NGINX**: `srcs/requirements/nginx/conf/nginx.conf` (`listen`), `srcs/docker-compose.yml` (`ports`), `srcs/requirements/nginx/Dockerfile` (`EXPOSE`)
- **MariaDB**: `srcs/requirements/mariadb/conf/50-server.cnf` (`port`), `srcs/requirements/wordpress/tools/init_wp.sh` (`-P` flag and `--dbhost`)

After any port change, perform a full clean rebuild so WordPress reinstalls with the correct URL stored in its database:
```bash
make fclean
sudo rm -rf ~/data/html/*
sudo rm -rf ~/data/mariadb/*
make
```