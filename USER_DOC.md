# User Documentation

## Overview

This project deploys a complete WordPress website using Docker Compose.

The stack contains the following services:

* Nginx: Web server and reverse proxy.
* WordPress: PHP application used to manage website content.
* MariaDB: Database server used by WordPress.
* Docker Volumes: Persistent storage for WordPress files and database data.

---

## Starting the Project

Build and start all services:

```bash
make
```

or

```bash
make up
```

Verify that containers are running:

```bash
docker ps
```

---

## Stopping the Project

Stop all containers:

```bash
make down
```

Stop and remove containers, networks, and volumes:

```bash
make fclean
```

---

## Accessing the Website

Open a browser and navigate to:

```text
https://<domain-name>
```

Example:

```text
https://myda-chi.42.fr
```

---

## Accessing the WordPress Administration Panel

Open:

```text
https://<domain-name>/wp-admin
```

Login using the administrator credentials configured during installation.

---

## Credentials

Credentials are stored in environment variables and Docker secrets.

Common credentials include:

* WordPress administrator account
* WordPress database user
* MariaDB root user

Configuration files are located in:

```text
srcs/.env
```

or

```text
srcs/secrets/
```

depending on the project implementation.

Never share these credentials publicly.

---

## Checking Service Status

List running containers:

```bash
docker ps
```

View logs:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Check container health:

```bash
docker compose ps
```

Expected services:

* nginx
* wordpress
* mariadb

All services should be in the "running" state.
