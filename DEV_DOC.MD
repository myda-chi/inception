# Developer Documentation

## Prerequisites

Required software:

* Docker
* Docker Compose
* GNU Make

Verify installation:

```bash
docker --version
docker compose version
make --version
```
---

## Project Structure

Example structure:

```text
.
├── Makefile
├── docker-compose.yml
├── srcs
│   ├── requirements
│   │   ├── nginx
│   │   ├── wordpress
│   │   └── mariadb
│   └── .env
├── USER_DOC.md
└── DEV_DOC.md
```

---

## Environment Configuration

Create or update:

```text
srcs/.env
```

Typical variables:

```env
DOMAIN_NAME=myda-chi.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=********

MYSQL_ROOT_PASSWORD=********

WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=********
```

If Docker secrets are used, place secret files in:

```text
srcs/secrets/
```

---

## Building the Project

Build all images:

```bash
make build
```
or
```bash
docker compose build
```
---
## Launching the Project

Start all services:

```bash
make
```
or
```bash
docker compose up -d
```
---
## Container Management

List containers:

```bash
docker ps
```

Open a shell inside a container:

```bash
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it nginx bash
```

View logs:

```bash
docker logs wordpress
docker logs mariadb
docker logs nginx
```

Restart a service:

```bash
docker restart wordpress
```
---

## Volume Management

List volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect wp-files
docker volume inspect wp-database
```

Remove unused volumes:

```bash
docker volume prune
```
---

## Persistent Data

WordPress data:

```text
/home/myda-chi/data/html
```

Mounted inside the container:

```text
/var/www/html
```
MariaDB data:

```text
/home/myda-chi/data/mariadb
```

Mounted inside the container:

```text
/var/lib/mysql
```

These directories are bind-mounted through Docker volumes and persist even if containers are recreated.

---

## Full Cleanup

Remove containers, networks, images, and volumes:

```bash
make fclean
```
or

```bash
docker compose down -v
```
Use with caution because database data may be permanently removed.
