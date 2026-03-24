*This project has been created as part of the 42 curriculum by hugo-mar.*

# Inception

## Description

The goal of this project is to set up a small, production-like infrastructure using Docker.
It consists of multiple interconnected services running in isolated containers, orchestrated using Docker Compose.

The architecture includes:

* A MariaDB database service
* A WordPress application running with PHP-FPM
* An NGINX web server acting as a reverse proxy with TLS (HTTPS)

All services are containerized and communicate through a Docker network. Data persistence is ensured using volumes.

The main objective is to understand how services interact in a real-world environment while applying best practices in containerization, security, and system design.

## Architecture

```
Client (Browser)
│ HTTPS (443)
▼
NGINX (TLS)
│ FastCGI (9000)
▼
WordPress (PHP-FPM)
│ MySQL (3306)
▼
MariaDB
```

## Instructions

### Requirements

* Linux environment (Debian recommended)
* Docker
* Docker Compose

### Setup

```
git clone git@github.com:hugo-mar/inception.git
cd inception
```

### Secrets setup

Create the following files before running the project:

* secrets/db_root_password.txt
* secrets/db_password.txt
* secrets/credentials.txt

Example:
```
echo "dbroot_42secure" > secrets/db_root_password.txt
echo "wpdb_42secure" > secrets/db_password.txt
echo -e "wpadmin_42secure\nwpuser_42secure" > secrets/credentials.txt
```
Important:
The credentials.txt file must contain exactly two lines:
* The first line is the WordPress admin password
* The second line is the secondary user password
If this format is not respected, the WordPress setup script will fail.

### Usage

To start the project, simply run:
```
make
```
This will:
* build all Docker images
* create required directories
* start all services (MariaDB, WordPress, NGINX)

## Available commands

```
make			# Build and start everything
make up			# Start services
make down		# Stop services
make clean		# Stop and remove containers + volumes
make fclean		# Full reset (including data)
make re			# Rebuild everything from scratch
make logs		# Show logs
make ps			# Show container status
```

### Access

Add to /etc/hosts:
```
127.0.0.1 hugo-mar.42.fr
```

Open:
```
https://hugo-mar.42.fr
```
Note: The browser will display a warning due to the self-signed certificate.

## Environment Variables

The project uses a `.env` file to configure the services.

It contains the following variables:
* DOMAIN_NAME — domain used to access the website
* DB_NAME — WordPress database name
* DB_USER — database user
* DB_HOST — database service address (Docker service name + port)
* WP_TITLE — website title
* WP_ADMIN_USER — administrator username
* WP_ADMIN_EMAIL — administrator email
* WP_USER — secondary WordPress user
* WP_USER_EMAIL — secondary user email
Note: Sensitive data such as passwords are not stored in the `.env` file but handled using Docker secrets.

## Technical Choices

Docker was chosen to ensure:

* service isolation
* reproducibility
* easy deployment

### Virtual Machines vs Docker

Virtual Machines (VMs) emulate an entire operating system, including the kernel, which makes them heavier in terms of resource usage and slower to start. Each VM runs independently with its own OS, which provides strong isolation but at the cost of performance and efficiency.

Docker, on the other hand, uses containerization, where applications share the host system’s kernel while remaining isolated at the process level. This makes containers significantly lighter, faster to start, and more efficient in terms of resource usage. For this project, Docker was chosen because it allows running multiple services in a reproducible and lightweight environment, closer to real-world deployment practices.
* VMs: heavy, full OS, slower
* Docker: lightweight, fast, efficient

### Secrets vs Environment Variables

Environment variables are commonly used to pass configuration values to containers, but they are not designed for sensitive data. They can be easily exposed through logs, container inspection commands, or process listings.

Docker secrets provide a more secure mechanism for handling sensitive information such as passwords. They are mounted as files inside the container and are not directly visible through standard inspection tools. In this project, secrets are used for database credentials to improve security and follow best practices.
* Secrets: secure, hidden
* Env vars: visible, less secure

### Docker Network vs Host Network

By default, Docker creates isolated virtual networks that allow containers to communicate securely using internal DNS resolution. This means services can refer to each other by name (e.g., mariadb, wordpress) without exposing ports externally.

Using the host network removes this isolation and makes containers share the host’s network stack directly, which can introduce security risks and port conflicts. In this project, a Docker network is used to ensure proper isolation while still allowing communication between services.
* Docker network: isolated, secure
* Host network: shared, less secure

### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and stored in its internal storage system. They are portable, easier to manage, and independent from the host filesystem structure.

Bind mounts, on the other hand, map a specific directory from the host into the container. This provides more control and transparency over the data, but also introduces potential permission and security issues.

In this project, bind mounts are used through Docker volumes configured with host paths (/home/hugo-mar/data/...). This ensures data persistence while allowing direct access and inspection from the host system, which is useful during development and debugging.
* Docker volumes: managed by Docker
* Bind mounts: managed by host

This project uses Docker named volumes mapped to:
```
/home/hugo-mar/data/
```

## Security

* HTTPS via NGINX
* Only port 443 exposed
* Secrets used for credentials
* Service isolation

## Resources

* Docker Docs: https://docs.docker.com/
* NGINX Docs: https://nginx.org/en/docs/
* WordPress Docs: https://developer.wordpress.org/
* MariaDB Docs: https://mariadb.org/documentation/

## Use of AI

AI was used to:

* Understand concepts
* Debug issues
* Improve project structure

All generated content was reviewed and understood.

## Final Notes

This project demonstrates:

* Docker Compose orchestration
* Service networking
* Secure configuration
* Persistent storage
