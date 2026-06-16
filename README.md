*This project has been created as part of the 42 curriculum by myda-chi.*

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small but complete web infrastructure using Docker and Docker Compose, entirely inside a virtual machine.

The infrastructure is composed of three services, each running in its own dedicated container:
- **NGINX** — the only entry point, serving HTTPS traffic on port 443 using TLSv1.2/TLSv1.3
- **WordPress + PHP-FPM** — the web application, configured without NGINX
- **MariaDB** — the relational database storing all WordPress data

All containers are built from scratch using custom Dockerfiles based on Debian Bookworm (penultimate stable version). No pre-built images from Docker Hub are used (except the base OS).

### Docker in this project

Docker is used to isolate each service in its own container, ensuring that services are independent, reproducible, and easy to manage. Each service communicates through a custom Docker bridge network named `inception`. Persistent data is stored using named Docker volumes.

### Design Choices

#### Virtual Machines vs Docker
| Virtual Machines | Docker |
|-----------------|--------|
| Emulates full hardware | Shares host OS kernel |
| Heavy — GBs of disk, minutes to start | Lightweight — MBs, starts in seconds |
| Full OS isolation | Process-level isolation |
| Good for running different OSes | Good for running multiple services |

In this project, a VM (VirtualBox + Debian) is used to host Docker — giving us a controlled Linux environment on any host machine. Docker then runs our three services inside the VM.

#### Secrets vs Environment Variables
| Environment Variables | Docker Secrets |
|----------------------|----------------|
| Stored in `.env` file | Stored as files, mounted in container |
| Visible in `docker inspect` | Not exposed in container environment |
| Simple to use | More secure for production |
| Risk of accidental exposure in logs | Designed for sensitive credentials |

In this project, environment variables via `.env` are used for configuration. The `.env` file is excluded from git via `.gitignore` to prevent credential exposure.

#### Docker Network vs Host Network
| Docker Network (bridge) | Host Network |
|------------------------|--------------|
| Containers communicate via service name | Containers share host network stack |
| Network isolation between containers | No isolation |
| Custom subnets possible | Uses host ports directly |
| Recommended for multi-container apps | Forbidden in this project |

This project uses a custom bridge network named `inception`. Containers reach each other by service name (e.g. `wordpress` connects to `mariadb` by hostname).

#### Docker Volumes vs Bind Mounts
| Docker Volumes | Bind Mounts |
|---------------|-------------|
| Managed by Docker | Maps host path directly |
| Stored in Docker's directory | Stored anywhere on host |
| Portable and recommended | Less portable |
| Named volumes persist across rebuilds | Depends on host path existing |

This project uses named volumes with `driver: local` and `driver_opts` to store data at `/home/myda-chi/data` on the host, satisfying both the named volume requirement and the specific storage path required by the subject.

## Instructions

### Prerequisites
- VirtualBox installed on your host machine
- Debian 12 (Bookworm) installed inside the VM
- Docker Engine and Docker Compose plugin installed in the VM

### Installation

1. Clone the repository inside the VM:
```bash
git clone -b master https://github.com/myda-chi/inception.git ~/Inception
cd ~/Inception
```

2. Add your domain to `/etc/hosts`:
```bash
echo "127.0.0.1 myda-chi.42.fr" | sudo tee -a /etc/hosts
```

3. Create the `.env` file at `srcs/.env` with your credentials (see `srcs/.env.example`).

4. Build and start the project:
```bash
make
```

5. Access the website at `https://myda-chi.42.fr`

### Makefile commands
| Command | Description |
|---------|-------------|
| `make` | Build and start all containers |
| `make down` | Stop all containers |
| `make re` | Rebuild and restart |
| `make clean` | Stop and remove containers and volumes |
| `make fclean` | Full cleanup including images |

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [OpenSSL self-signed certificates](https://www.openssl.org/docs/)
- [TLS/SSL overview](https://www.cloudflare.com/learning/ssl/what-is-tls/)

### AI Usage

Claude AI (Anthropic) was used throughout this project for the following tasks:

- **Understanding Docker concepts** — explaining images, containers, volumes, networks, and how they interact
- **Dockerfile writing** — learning best practices such as avoiding `tail -f`, using `exec` form for CMD, and running processes in the foreground
- **NGINX configuration** — setting up TLS, FastCGI pass to PHP-FPM, and understanding `fastcgi_params`
- **MariaDB initialization** — writing the `init_db.sh` script to create the database and user on first run
- **WordPress automation** — using WP-CLI to install and configure WordPress non-interactively via `init_wp.sh`
- **Debugging** — diagnosing 403, 502, and redirect loop errors by analyzing container logs
- **Documentation** — structuring and writing this README, USER_DOC.md, and DEV_DOC.md
