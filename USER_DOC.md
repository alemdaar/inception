# User Documentation

## 1. Overview

This document explains how to use and administer the Inception infrastructure.

The stack provides the following services:

| Service        | Purpose                    | Access                  |
| -------------- | -------------------------- | ----------------------- |
| Nginx          | HTTPS entry point          | `https://localhost`     |
| WordPress      | Main website               | `https://localhost`     |
| MariaDB        | WordPress database         | Internal only           |
| Redis          | WordPress object cache     | Internal only           |
| FTP            | Access to WordPress files  | `localhost:21`          |
| Adminer        | Database administration    | `http://localhost:8081` |
| Static Website | Independent static website | `http://localhost:8080` |
| Status         | Infrastructure status page | `http://localhost:8082` |

---

## 2. Starting the Project

From the project root directory:

```bash
make
```

This builds the required Docker images and starts the services.

Check that the containers are running:

```bash
docker ps
```

All required services should have a status similar to:

```text
Up
```

---

## 3. Stopping the Project

To stop the infrastructure:

```bash
make down
```

Alternatively:

```bash
docker compose -f srcs/docker-compose.yml down
```

Stopping the containers does not normally remove the persistent WordPress and MariaDB data.

---

## 4. Accessing WordPress

The main website is served through Nginx using HTTPS:

```text
https://localhost
```

Because the project uses a locally generated TLS certificate, the browser may display a certificate warning.

This is expected for a self-signed development certificate.

Proceed to the website after accepting the browser's certificate warning.

---

## 5. Accessing the WordPress Administration Panel

The WordPress administration interface is available at:

```text
https://localhost/wp-admin
```

Use the WordPress administrator credentials configured during the project setup.

The WordPress credentials should be kept private and must not be committed to the repository.

---

## 6. Adminer

Adminer is a web-based database administration interface.

Open:

```text
http://localhost:8081
```

Adminer should display its login page.

### Connection information

Because Adminer runs inside the Docker network, the database server should be specified using the Docker Compose service name:

```text
Server: mariadb
```

The database credentials are the MariaDB credentials configured in the project's environment configuration.

Typical fields are:

```text
System: MySQL
Server: mariadb
Username: <database user>
Password: <database password>
Database: <WordPress database>
```

Do not use `localhost` as the database server from inside the Adminer container.

`localhost` would refer to the Adminer container itself, not the MariaDB container.

---

## 7. FTP

The FTP service provides access to the WordPress filesystem.

Connect to:

```text
localhost:21
```

For example, using the command-line FTP client:

```bash
ftp localhost
```

Then enter the FTP username and password configured for the project.

After logging in:

```text
ftp> ls
```

The files shown should correspond to the WordPress files stored in the shared WordPress volume.

For example:

```text
wp-admin/
wp-content/
wp-includes/
wp-config.php
index.php
```

### Why does FTP use the WordPress volume?

FTP is intended to manage WordPress files.

Therefore it uses the same persistent WordPress volume mounted by the WordPress container.

This means that a file uploaded or modified through FTP is immediately available to WordPress.

MariaDB is not used because it contains database files rather than the WordPress application's website files.

---

## 8. Redis

Redis is used as an object cache for WordPress.

Check that the Redis container is running:

```bash
docker ps
```

Test Redis directly:

```bash
docker exec redis redis-cli ping
```

Expected output:

```text
PONG
```

Check the WordPress Redis integration:

```bash
docker exec wordpress wp redis status --allow-root --path=/var/www/html
```

A working configuration should show:

```text
Status: Connected
Ping: PONG
```

Redis communicates with WordPress using the Docker service name:

```text
redis
```

and port:

```text
6379
```

---

## 9. Static Website

The static website is independent from WordPress.

Open:

```text
http://localhost:8080
```

The website consists of static files such as HTML and CSS and does not require PHP execution.

This demonstrates that a separate website can run as an independent Docker service.

---

## 10. Status Service

The custom status service provides a simple dashboard describing the infrastructure.

Open:

```text
http://localhost:8082
```

The page displays the services included in the project.

The current implementation is a static status page. The displayed service states are therefore informational and are not automatically updated when a container is stopped.

For real-time verification, use Docker commands such as:

```bash
docker ps
```

or:

```bash
docker inspect <container>
```

---

## 11. Checking Service Health

### Check all containers

```bash
docker ps
```

### Check all containers, including stopped ones

```bash
docker ps -a
```

### Check a service's logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs redis
docker logs ftp
docker logs adminer
```

### Follow logs in real time

```bash
docker logs -f <container>
```

For example:

```bash
docker logs -f wordpress
```

Press `Ctrl+C` to stop following the logs.

---

## 12. Checking the Docker Network

The services communicate through the project's Docker network.

List networks:

```bash
docker network ls
```

Inspect the Inception network:

```bash
docker network inspect srcs_inception
```

The containers should appear as members of the network.

Services can communicate using their Compose service names, for example:

```text
wordpress → mariadb
wordpress → redis
adminer → mariadb
```

---

## 13. Managing Persistent Data

The project stores persistent data for:

* MariaDB
* WordPress

The configured storage locations are:

```text
/home/<login>/data/mariadb_data
/home/<login>/data/wordpress_data
```

These locations contain data that must survive container recreation.

### Check the directories

```bash
ls -la /home/$USER/data/
```

### Check Docker volumes

```bash
docker volume ls
```

### Inspect a volume

```bash
docker volume inspect mariadb_data
```

or:

```bash
docker volume inspect wordpress_data
```

Be careful when deleting volumes because this can permanently remove persistent application data.

---

## 14. Useful Troubleshooting Commands

If a service is not working, first check:

```bash
docker ps -a
```

Then inspect its logs:

```bash
docker logs <container>
```

Check the network:

```bash
docker network inspect srcs_inception
```

Check the published ports:

```bash
docker port <container>
```

For example:

```bash
docker port nginx
docker port adminer
docker port ftp
```

Test HTTP services directly:

```bash
curl -I http://localhost:8080
curl -I http://localhost:8081/adminer.php
curl -I http://localhost:8082
```

Test HTTPS:

```bash
curl -k -I https://localhost
```

The `-k` option allows testing the HTTPS service without validating the self-signed certificate.

---

## 15. Credentials

Credentials are stored in the project's configuration/secrets and should never be exposed publicly.

Administrators should consult the configured environment/secrets files when they need:

* MariaDB credentials
* WordPress database credentials
* WordPress administrator credentials
* FTP credentials

Do not publish these credentials in Git, screenshots, documentation, or public repositories.

---

## 16. Safe Administration Practices

Before removing containers or volumes:

1. Check whether persistent data is required.
2. Back up important data.
3. Check the current Docker volumes.
4. Only then perform cleanup commands.

For normal troubleshooting, prefer:

```bash
docker logs
docker ps
docker inspect
docker network inspect
```

before deleting containers or volumes.

