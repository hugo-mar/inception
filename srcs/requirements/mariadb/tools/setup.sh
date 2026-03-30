#!/bin/bash
# Exit immediately if any command fails
set -e

# Define important MariaDB paths
MYSQL_DATA_DIR="/var/lib/mysql"
MYSQL_SOCKET="/run/mysqld/mysqld.sock"

# Ensure required Docker secrets exist before continuing
[ -f /run/secrets/db_root_password ] || { echo "Missing /run/secrets/db_root_password"; exit 1; }
[ -f /run/secrets/db_password ] || { echo "Missing /run/secrets/db_password"; exit 1; }

# Read configuration values from secrets
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_PASSWORD="$(cat /run/secrets/db_password)"

# Ensure mandatory environment variables/secrets are defined
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_ROOT_PASSWORD:?db_root_password secret is required}"
: "${DB_PASSWORD:?db_password secret is required}"

# Ensure the MariaDB runtime directory exists and has correct ownership
# This directory will contain the socket and PID file
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$MYSQL_DATA_DIR"

# Check if the MariaDB data directory has already been initialized
# If the system tables do not exist, we perform the initial setup
if [ ! -d "$MYSQL_DATA_DIR/mysql" ]; then
	echo "Initialising MariaDB database..."

	# Create the initial MariaDB system tables inside the data directory
	mysql_install_db --user=mysql --datadir="$MYSQL_DATA_DIR" > /dev/null

	echo "Starting temporary MariaDB server..."

	# Start MariaDB in the background without networking
	# This server is only used to perform the initial configuration
	mysqld --user=mysql --datadir="$MYSQL_DATA_DIR" --socket="$MYSQL_SOCKET" --skip-networking &
	pid="$!"

	echo "Waiting for MariaDB to be ready..."

	# Wait until the server responds to mysqladmin ping
	# Retry for up to 30 seconds before failing
	tries=30
	until mysqladmin --socket="$MYSQL_SOCKET" -u root ping > /dev/null 2>&1; do
		tries=$((tries - 1))
		if [ "$tries" -le 0 ]; then
			echo "ERROR: MariaDB did not become ready in time."
			# Attempt to stop the temporary server before exiting
			kill "$pid" 2>/dev/null || true
			exit 1
		fi
		sleep 1
	done

	echo "Configuring MariaDB..."

	# Execute SQL commands to configure the database:
	# - Set the root password
	# - Remove anonymous users created by the default MariaDB installation
	# - Remove the default "test" database
	# - Create the application database
	# - Create the application user
	# - Grant privileges on the database
	mysql --socket="$MYSQL_SOCKET" -u root <<-EOF
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
	DELETE FROM mysql.user WHERE User='';
	DROP DATABASE IF EXISTS test;
	CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
	CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
	GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
	FLUSH PRIVILEGES;
	EOF

	echo "Stopping temporary MariaDB server..."

	# Gracefully stop the temporary MariaDB instance
	mysqladmin --socket="$MYSQL_SOCKET" -u root -p"${DB_ROOT_PASSWORD}" shutdown

	# Wait for the background process to fully terminate
	wait "$pid" || true

	echo "MariaDB initialisation complete."
fi

echo "Starting MariaDB..."

# Replace the shell process with the MariaDB server
# This ensures MariaDB becomes PID 1 inside the container
exec mysqld --user=mysql --datadir="$MYSQL_DATA_DIR" --socket="$MYSQL_SOCKET"