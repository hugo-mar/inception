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

## Instructions

### Requirements

* Linux environment (Debian recommended)
* Docker
* Docker Compose

### Setup

git clone <repository_url>
cd inception

### Secrets setup

Create the following files before running the project:

secrets/db_root_password.txt
secrets/db_password.txt
secrets/credentials.txt

Example:

echo "root_password" > secrets/db_root_password.txt
echo "user_password" > secrets/db_password.txt
echo -e "admin_pass\nuser_pass" > secrets/credentials.txt

### Run

make

### Access

Add to /etc/hosts:

127.0.0.1 hugo-mar.42.fr

Open:

https://hugo-mar.42.fr

Note: The browser will display a warning due to the self-signed certificate.

## Environment Variables

The project uses a `.env` file to store configuration such as:

* domain name
* database name
* usernames

## Makefile Commands

make        # Build and start everything
make up     # Start services
make down   # Stop services
make clean  # Stop and remove containers + volumes
make fclean # Full reset (including data)
make re     # Rebuild everything from scratch
make logs   # Show logs
make ps     # Show container status

## Technical Choices

Docker was chosen to ensure:

* service isolation
* reproducibility
* easy deployment

### Virtual Machines vs Docker

VMs: heavy, full OS, slower
Docker: lightweight, fast, efficient

### Secrets vs Environment Variables

Secrets: secure, hidden
Env vars: visible, less secure

### Docker Network vs Host Network

Docker network: isolated, secure
Host network: shared, less secure

### Docker Volumes vs Bind Mounts

Docker volumes: managed by Docker
Bind mounts: managed by host

This project uses Docker named volumes mapped to:

/home/hugo-mar/data/

## Security

* HTTPS via NGINX
* Only port 443 exposed
* Secrets used for credentials
* Service isolation

## Resources

Docker Docs: https://docs.docker.com/
NGINX Docs: https://nginx.org/en/docs/
WordPress Docs: https://developer.wordpress.org/
MariaDB Docs: https://mariadb.org/documentation/

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
