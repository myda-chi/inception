# User Documentation

This document explains how to use the Inception stack as an end user or administrator — no development knowledge required.

## What services does this stack provide?

The stack is made of three services working together to run a WordPress website:

| Service | Role |
|---------|------|
| **NGINX** | The only entry point to the site. Handles HTTPS (TLSv1.2/TLSv1.3) on port 443 and forwards requests to WordPress. |
| **WordPress + PHP-FPM** | Runs the WordPress application and generates the pages you see in the browser. |
| **MariaDB** | Stores all WordPress data — posts, pages, users, settings — in a database. |

You only ever interact with the site through NGINX; WordPress and MariaDB are not directly reachable from outside the stack.

## Starting the project

From the root of the repository, run:
```bash
make
```

This builds the Docker images (if needed) and starts all three containers in the background.

## Stopping the project

To stop the containers without deleting any data:
```bash
make down
```

To stop the containers **and** delete the stored data (database + website files):
```bash
make clean
```

To remove everything, including built Docker images:
```bash
make fclean
```

## Accessing the website

Open a browser and go to:
```
https://myda-chi.42.fr
```

Your browser will warn you about the certificate because it is self-signed. This is expected — click **Advanced** → **Accept the risk and continue** (the exact wording depends on your browser).

## Accessing the administration panel

Go to:
```
https://myda-chi.42.fr/wp-admin
```

Log in using the administrator credentials defined in the `.env` file (see below).

## Locating and managing credentials

All credentials are defined in the `srcs/.env` file at the root of the `srcs/` folder. This file contains:

- Database name, user, and passwords (`MYSQL_*`)
- WordPress admin username, password, and email (`WP_ADMIN_*`)
- A second WordPress user (`WP_USER*`)
- The site domain name (`DOMAIN_NAME`)

This file is never committed to git (it is listed in `.gitignore`) to keep credentials private. If you need to change a password, edit `srcs/.env`, then rebuild the project from a clean state:
```bash
make fclean
sudo rm -rf ~/data/html/*
sudo rm -rf ~/data/mariadb/*
make
```

This is necessary because WordPress and MariaDB only read these values the first time they initialize.

## Checking that services are running correctly

To see the status of all containers:
```bash
docker compose -f srcs/docker-compose.yml ps
```

All three services (`nginx`, `wordpress`, `mariadb`) should show a status of **Up**.

To check the logs of a specific service if something looks wrong:
```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

If a container keeps restarting, the logs will usually show the exact error near the bottom of the output.