# Developer Documentation

## 1. Overview

This document explains how to set up, build, run, manage, and develop the Inception infrastructure.

The project is based on Docker and Docker Compose. Each service runs in its own container and communicates with the other services through a dedicated Docker network.

The infrastructure contains:

* Nginx
* WordPress
* MariaDB
* Redis
* FTP
* Adminer
* Static Website
* Status Service

---

## 2. Prerequisites

Before building the project, install:

* Docker
* Docker Compose
* Make
* Git

Verify the installation:

```bash
docker --version
docker compose version
make --version
git --version
```

The host system must also provide enough disk space and memory for all containers.

---

## 3. Project Structure

The main project structure is:

```text
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        ├── redis/
        ├── ftp/
        ├── adminer/
        ├── static/
        └── status/
```

Each service has its own build context and Dockerfile.

---

## 4. Configuration

The main Compose configuration is:

```text
srcs/docker-compose.yml
```

Environment variables are stored in:

```text
srcs/.env
```

The `.env` file contains configuration used by services such as MariaDB and WordPress.

Sensitive credentials must not be committed to Git.

For example, verify that `.env` is ignored before committing:

```bash
git status
```

If necessary, add it to `.gitignore`:

```text
srcs/.env
```

---

## 5. Persistent Storage

The project requires persistent storage for WordPress and MariaDB.

The configured host directories are:

```text
/home/<login>/data/mariadb_data
/home/<login>/data/wordpress_data
```

For the current user, they can be checked with:

```bash
echo $USER
ls -la /home/$USER/data/
```

The Makefile creates the required directories before starting Docker Compose.

The WordPress volume is mounted inside the relevant containers at:

```text
/var/www/html
```

The MariaDB volume is mounted at:

```text
/var/lib/mysql
```

This allows data to survive container recreation.

---

## 6. Building the Project

From the project root:

```bash
make
```

The Makefile prepares the required data directories and launches Docker Compose.

Docker Compose builds each service from its own Dockerfile.

To build directly without the Makefile:

```bash
docker compose -f srcs/docker-compose.yml up --build
```

To run the services in detached mode:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

---

## 7. Checking the Build

List all containers:

```bash
docker ps
```

List all containers, including stopped containers:

```bash
docker ps -a
```

List the images:

```bash
docker images
```

List the volumes:

```bash
docker volume ls
```

List the networks:

```bash
docker network ls
```

---

## 8. Managing Containers

### Start the project

```bash
make
```

### Stop the project

```bash
make down
```

or:

```bash
docker compose -f srcs/docker-compose.yml down
```

### Restart the project

```bash
docker compose -f srcs/docker-compose.yml restart
```

### Restart one service

```bash
docker compose -f srcs/docker-compose.yml restart wordpress
```

### Stop one container

```bash
docker stop wordpress
```

### Start one stopped container

```bash
docker start wordpress
```

### Remove containers

```bash
docker compose -f srcs/docker-compose.yml down
```

---

## 9. Inspecting Containers

Inspect a container:

```bash
docker inspect wordpress
```

Check its published ports:

```bash
docker port nginx
docker port adminer
docker port ftp
```

Open a shell inside a container:

```bash
docker exec -it wordpress bash
```

For containers without Bash:

```bash
docker exec -it <container> sh
```

Execute a command without opening a shell:

```bash
docker exec wordpress ls -la /var/www/html
```

---

## 10. Logs and Debugging

View logs:

```bash
docker logs wordpress
```

Follow logs:

```bash
docker logs -f wordpress
```

Check the logs of all Compose services:

```bash
docker compose -f srcs/docker-compose.yml logs
```

Follow all logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

When debugging a service, check:

1. Container status.
2. Container logs.
3. Network membership.
4. Published ports.
5. Configuration files.
6. Volume mounts.
7. Dependencies.

---

## 11. Docker Network

The project uses a dedicated Docker bridge network.

List networks:

```bash
docker network ls
```

Inspect the project network:

```bash
docker network inspect srcs_inception
```

The containers should appear as members of the network.

Docker Compose provides service-name-based DNS inside the network.

For example:

```text
wordpress → mariadb:3306
wordpress → redis:6379
adminer → mariadb:3306
```

This is preferable to using container IP addresses because container IP addresses can change.

---

## 12. MariaDB Development

Enter the MariaDB container:

```bash
docker exec -it mariadb bash
```

Check that MariaDB is running:

```bash
docker exec mariadb mariadb-admin ping
```

A successful result indicates that the database server is responding.

MariaDB stores its persistent database files in:

```text
/var/lib/mysql
```

The directory is backed by the MariaDB Docker volume.

---

## 13. WordPress Development

The WordPress files are located at:

```text
/var/www/html
```

Inside the WordPress container:

```bash
docker exec wordpress ls -la /var/www/html
```

The WordPress configuration is stored in:

```text
/var/www/html/wp-config.php
```

WP-CLI can be used to inspect WordPress:

```bash
docker exec wordpress wp --info --allow-root
```

Check the WordPress installation:

```bash
docker exec wordpress wp core is-installed --allow-root --path=/var/www/html
```

Check Redis integration:

```bash
docker exec wordpress wp redis status --allow-root --path=/var/www/html
```

---

## 14. Redis Development

Redis listens internally on:

```text
6379
```

The WordPress container connects to Redis using:

```text
redis:6379
```

Test Redis:

```bash
docker exec redis redis-cli ping
```

Expected result:

```text
PONG
```

Check Redis information:

```bash
docker exec redis redis-cli INFO
```

The Redis service does not need to publish port 6379 to the host because WordPress accesses it through the Docker network.

---

## 15. FTP Development

The FTP service mounts the WordPress volume:

```text
/var/www/html
```

This allows the FTP user to access the same WordPress files used by the WordPress service.

Check the mounted files:

```bash
docker exec ftp ls -la /var/www/html
```

Check the FTP user:

```bash
docker exec ftp id ftpuser
```

The FTP service publishes:

```text
21
```

for the FTP control connection and:

```text
21100-21110
```

for passive FTP connections.

---

## 16. Adminer Development

Adminer runs its PHP development server inside its container.

The server listens internally on:

```text
8080
```

Docker publishes it to the host through:

```text
8081:8080
```

Therefore:

```text
Host:      localhost:8081
Container: adminer:8080
```

Test the service:

```bash
curl -I http://localhost:8081/adminer.php
```

A successful response should return HTTP status `200`.

Inside Adminer, MariaDB should be reached using:

```text
mariadb
```

rather than `localhost`.

---

## 17. Static Website Development

The static website runs independently from WordPress.

Its files are stored inside its own service directory.

For example:

```text
srcs/requirements/static/
```

The service uses Nginx to serve the static files.

The host accesses it through:

```text
http://localhost:8080
```

No PHP interpreter or PHP-FPM process is required for this service.

---

## 18. Status Service Development

The Status service is an additional custom service created for the bonus part.

Its purpose is to provide a simple page describing the infrastructure.

The service runs its own Nginx container and publishes:

```text
8082:80
```

Therefore:

```text
http://localhost:8082
```

can be used to access it.

The current status page is informational rather than a real-time monitoring system. Docker commands such as `docker ps` remain the authoritative way to verify whether containers are actually running.

---

## 19. Volumes

List volumes:

```bash
docker volume ls
```

Inspect the WordPress volume:

```bash
docker volume inspect wordpress_data
```

Inspect the MariaDB volume:

```bash
docker volume inspect mariadb_data
```

The volumes preserve data independently from the lifecycle of the containers.

Do not remove them during normal development unless you intentionally want to reset the project's persistent data.

---

## 20. Cleaning the Project

The Makefile provides cleanup commands.

A normal cleanup should remove containers and related build artifacts according to the project's Makefile.

Before using a complete cleanup command, verify that important persistent data is backed up.

To see the current Docker resources:

```bash
docker ps -a
docker images
docker volume ls
docker network ls
```

If persistent volumes are removed, the WordPress installation and MariaDB database may need to be recreated.

---

## 21. Rebuilding After Changes

After modifying a Dockerfile or service configuration, rebuild the project:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

If a service needs to be rebuilt specifically:

```bash
docker compose -f srcs/docker-compose.yml build wordpress
```

Then restart it:

```bash
docker compose -f srcs/docker-compose.yml up -d wordpress
```

After rebuilding, verify:

```bash
docker ps
docker compose -f srcs/docker-compose.yml logs wordpress
```

---

## 22. Development Workflow

A typical development workflow is:

```text
1. Modify configuration or source files
          ↓
2. Rebuild the affected service
          ↓
3. Start/restart the service
          ↓
4. Check container status
          ↓
5. Check logs
          ↓
6. Test the service
          ↓
7. Verify persistence and networking
```

Useful commands during development include:

```bash
docker ps
docker ps -a
docker logs <container>
docker inspect <container>
docker exec -it <container> bash
docker network inspect srcs_inception
docker volume ls
docker volume inspect <volume>
```

---

## 23. Data Persistence

The most important persistent data is:

### MariaDB

```text
/home/<login>/data/mariadb_data
```

Contains the MariaDB database data.

### WordPress

```text
/home/<login>/data/wordpress_data
```

Contains the WordPress installation, configuration, plugins, themes, uploads, and other WordPress files.

The FTP service also accesses the WordPress volume, allowing file modifications to be reflected directly in the WordPress installation.

---

## 24. Security Considerations

Developers should avoid:

* Committing `.env` files containing real credentials.
* Hard-coding passwords in Dockerfiles.
* Publishing internal database ports unnecessarily.
* Using container IP addresses instead of Docker service names.
* Deleting persistent volumes unintentionally.
* Exposing private credentials in documentation.

The main WordPress service is exposed through Nginx using HTTPS, while services such as MariaDB and Redis communicate internally through the Docker network.

---

## 25. Development Checklist

Before considering a modification complete:

```text
[ ] Dockerfile builds successfully
[ ] Container starts correctly
[ ] Container remains running
[ ] Service logs contain no critical errors
[ ] Service can communicate with required dependencies
[ ] Docker network configuration is correct
[ ] Required ports are accessible
[ ] Persistent data remains available
[ ] WordPress still works
[ ] Redis still connects to WordPress
[ ] MariaDB remains accessible
[ ] Bonus services still work
```

