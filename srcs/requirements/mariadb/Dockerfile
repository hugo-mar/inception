# Use Debian 12 as the base image
FROM debian:12

# Update package lists and install MariaDB server and client
# Clean apt cache afterwards to reduce image size
RUN apt-get update && apt-get install -y mariadb-server mariadb-client \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql/*

# Create the directory where MariaDB stores its socket and PID file
# Set ownership to the mysql user so the server can write to it
RUN mkdir -p /run/mysqld \
	&& chown -R mysql:mysql /run/mysqld \
	&& chmod 755 /run/mysqld

# Create the directory where the database files will be stored
# MariaDB needs proper ownership to access and modify these files
RUN mkdir -p /var/lib/mysql \
	&& chown -R mysql:mysql /var/lib/mysql \
	&& chmod 755 /var/lib/mysql

# Copy the custom MariaDB configuration file into the container
# This file typically contains settings like bind-address and other server options
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the initialization script that will configure and start MariaDB
COPY tools/setup.sh /usr/local/bin/setup.sh

# Make sure the script is executable
RUN chmod +x /usr/local/bin/setup.sh

# Expose the default MariaDB port
EXPOSE 3306

# Define the entrypoint script that will run when the container starts
# This script is responsible for initializing and launching the database server
ENTRYPOINT ["/usr/local/bin/setup.sh"]
