*This project has been created as part of the 42 curriculum by oelhasso.*

# Inception

## Description

Inception is a system administration and Docker project from the 42 curriculum. The goal is to build a complete web infrastructure using Docker Compose, where each service runs inside its own container.

The project provides a WordPress website served through Nginx, with MariaDB used as the database. The infrastructure is extended with Redis caching, an FTP server, Adminer, a static website, and a custom infrastructure status service.

The main services are:

* **Nginx** — HTTPS reverse proxy and the only public entry point for the main WordPress website.
* **WordPress** — Content management system running with PHP-FPM.
* **MariaDB** — Relational database used by WordPress.
* **Redis** — Object cache used by WordPress to improve performance.
* **FTP** — FTP server providing access to the WordPress files.
* **Adminer** — Web interface for managing the MariaDB database.
* **Static Website** — A simple website served independently from WordPress.
* **Status** — A custom service displaying the state of the infrastructure.

### Docker

Docker is used to isolate every service into its own container. Docker Compose is used to define the services, networks, volumes, dependencies, ports, and configuration required by the infrastructure.

This architecture provides:

* Service isolation
* Reproducible builds
* Easier service management
* Independent service configuration
* Internal communication through a Docker network
* Persistent data through volumes

The containers communicate using the Docker Compose network. Services can reach each other using their service names, such as `mariadb` or `redis`, instead of hard-coded IP addresses.

## Architecture

```text
                         Internet
                            |
                            | HTTPS :443
                            v
                     +-------------+
                     |    Nginx    |
                     +-------------+
                            |
                            v
                     +-------------+
                     |  WordPress  |
                     |   PHP-FPM   |
                     +-------------+
                       |          |
                       |          |
                       v          v
                 +---------+   +-------+
                 | MariaDB |   | Redis |
                 +---------+   +-------+
                      |
                 persistent data
                      |
                 +-------------+
                 | Docker      |
                 | Volume      |
                 +-------------+

Additional services:

     FTP :21                    Adminer :8081
       |                              |
       v                              v
 WordPress files                  MariaDB
       
     Static :8080                Status :8082
       |                              |
       v                              v
 Static website                 Status page
```

## Design Choices

### Virtual Machines vs Docker

A virtual machine emulates a complete computer and normally includes its own operating system and kernel. This provides strong isolation but requires more resources.

Docker containers share the host operating system kernel while isolating applications and their dependencies.

| Virtual Machines             | Docker                  |
| ---------------------------- | ----------------------- |
| Includes a complete guest OS | Shares the host kernel  |
| Higher resource usage        | Lower resource usage    |
| Usually slower to start      | Fast startup            |
| Strong isolation             | Process-level isolation |
| Larger disk footprint        | Smaller images          |

Docker was chosen because this project requires multiple isolated services that can communicate with each other while remaining lightweight and easy to manage.

### Secrets vs Environment Variables

Environment variables are convenient for configuring containers, but sensitive values can be exposed through configuration or container inspection.

Docker secrets are designed specifically for sensitive information such as passwords and credentials.

| Environment Variables                    | Secrets                           |
| ---------------------------------------- | --------------------------------- |
| Simple to configure                      | Designed for sensitive data       |
| Convenient for normal configuration      | Better protection for credentials |
| Can expose sensitive values more easily  | Credentials are mounted as files  |
| Suitable for non-sensitive configuration | Suitable for passwords and keys   |

The project uses environment variables for configuration and credentials where required by the project structure, while sensitive information should preferably be handled through Docker secrets when possible.

### Docker Network vs Host Network

With a Docker bridge network, containers communicate through an isolated virtual network.

For example:

```text
wordpress → mariadb:3306
wordpress → redis:6379
```

The services do not need to know each other's IP addresses.

Host networking removes this isolation and makes containers use the host's network namespace.

| Docker Network                         | Host Network                       |
| -------------------------------------- | ---------------------------------- |
| Network isolation                      | No network isolation               |
| Containers communicate by service name | Uses host network directly         |
| Better service separation              | Less isolation                     |
| Port publishing is controlled          | Ports are directly exposed on host |

The project uses a dedicated Docker bridge network called `inception`.

### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and are designed to persist container data.

Bind mounts directly map a host filesystem path into a container.

| Docker Volumes                     | Bind Mounts                                |
| ---------------------------------- | ------------------------------------------ |
| Managed by Docker                  | Managed directly by the host               |
| Portable Docker configuration      | Depends on host paths                      |
| Docker controls the storage        | User controls the exact location           |
| Good for persistent container data | Useful when direct host access is required |

For this project, persistent WordPress and MariaDB data are stored using Docker volumes configured with the required host storage locations.

## Services

### Nginx

Nginx is the main entry point for the WordPress website.

It:

* Accepts HTTPS connections on port 443.
* Uses TLS.
* Serves WordPress static files.
* Sends PHP requests to PHP-FPM.
* Acts as the reverse proxy for the WordPress application.

### WordPress

WordPress provides the web application.

It uses:

* PHP-FPM
* MariaDB
* Redis object caching

WP-CLI is used during initialization to install and configure WordPress.

### MariaDB

MariaDB stores the WordPress database.

The database data is stored persistently so that removing or recreating the MariaDB container does not remove the database.

### Redis

Redis provides object caching for WordPress.

The Redis WordPress plugin connects to:

```text
redis:6379
```

This allows frequently accessed WordPress objects to be cached in memory.

### FTP

The FTP service provides access to the WordPress filesystem.

It points to the same WordPress volume so that files uploaded or modified through FTP are directly available to WordPress.

### Adminer

Adminer provides a web interface for managing MariaDB.

It is accessible through:

```text
http://localhost:8081
```

Adminer connects to MariaDB using the Docker service name:

```text
mariadb
```

### Static Website

The static website is a simple website served independently from WordPress.

It does not require PHP or another server-side application runtime.

It is accessible through:

```text
http://localhost:8080
```

### Status

The Status service provides a simple infrastructure dashboard showing the services included in the project.

It is accessible through:

```text
http://localhost:8082
```

## Instructions

### Prerequisites

The following software is required:

* Docker
* Docker Compose
* Make

### Configuration

Create the required environment configuration in:

```text
srcs/.env
```

The environment file contains the configuration required by the MariaDB and WordPress services.

Credentials must not be committed to the Git repository.

### Build and Start

From the project root:

```bash
make
```

This creates the required data directories and builds/starts the Docker Compose infrastructure.

### Stop the Project

```bash
make down
```

or:

```bash
docker compose -f srcs/docker-compose.yml down
```

### Remove Containers and Persistent Data

Use the project's clean targets when appropriate:

```bash
make clean
```

or:

```bash
make fclean
```

Be careful with commands that remove volumes because persistent WordPress and MariaDB data can be deleted.

### Check Running Services

```bash
docker ps
```

To inspect the Docker network:

```bash
docker network inspect srcs_inception
```

To inspect a specific service:

```bash
docker logs wordpress
docker logs mariadb
docker logs nginx
docker logs redis
docker logs ftp
docker logs adminer
```

### Test Redis

```bash
docker exec redis redis-cli ping
```

Expected result:

```text
PONG
```

Check the WordPress Redis connection:

```bash
docker exec wordpress wp redis status --allow-root --path=/var/www/html
```

The status should report:

```text
Status: Connected
Ping: PONG
```

### Access the Services

| Service        | Address                 |
| -------------- | ----------------------- |
| WordPress      | `https://localhost`     |
| Adminer        | `http://localhost:8081` |
| Static Website | `http://localhost:8080` |
| Status         | `http://localhost:8082` |
| FTP            | `localhost:21`          |

## Persistence

The project uses persistent storage for the main application data.

MariaDB data is stored in:

```text
/home/<login>/data/mariadb_data
```

WordPress files are stored in:

```text
/home/<login>/data/wordpress_data
```

The exact paths are configured through the Docker Compose volume definitions.

This ensures that recreating containers does not automatically remove the application data.

## Resources

The project relies on the following types of resources:

* Docker documentation — Docker concepts, images, containers, networks and volumes.
* Docker Compose documentation — Service orchestration and Compose configuration.
* Nginx documentation — HTTP server, reverse proxy and TLS configuration.
* WordPress documentation — WordPress installation and configuration.
* WP-CLI documentation — Command-line WordPress management.
* MariaDB documentation — Database administration and configuration.
* Redis documentation — Redis server and caching concepts.
* Adminer documentation — Database administration through the web interface.
* vsftpd documentation — FTP server configuration.
* PHP documentation — PHP-FPM and PHP's built-in web server.

### AI Usage

AI tools were used as a learning and development assistant during the project.

AI was used for:

* Understanding Docker and Docker Compose concepts.
* Understanding container networking and service discovery.
* Debugging Docker build and runtime errors.
* Understanding Nginx and PHP-FPM configuration.
* Understanding WordPress and WP-CLI configuration.
* Configuring and troubleshooting Redis object caching.
* Understanding FTP and shared WordPress volumes.
* Understanding Adminer and MariaDB connectivity.
* Explaining Linux and Docker commands.
* Reviewing configuration files and identifying errors.
* Helping structure and improve the project's documentation.

AI-generated explanations and suggestions were reviewed and tested against the actual project environment before being used.

## Project Structure

```text
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── srcs/
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       ├── wordpress/
│       ├── redis/
│       ├── ftp/
│       ├── adminer/
│       ├── static/
│       └── status/
```

## Conclusion

The project demonstrates how to design, build and manage a multi-service web infrastructure using Docker and Docker Compose.

Each component has a dedicated responsibility and runs in its own container while communicating with the other services through the dedicated Docker network.

