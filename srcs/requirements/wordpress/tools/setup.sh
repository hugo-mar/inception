#!/bin/bash
set -e

# Define the WordPress installation directory
WP_PATH="/var/www/html"

# Ensure required secrets exist before continuing
[ -f /run/secrets/db_password ] || { echo "Missing /run/secrets/db_password"; exit 1; }
[ -f /run/secrets/credentials ] || { echo "Missing /run/secrets/credentials"; exit 1; }

# Read database password from Docker secret
DB_PASSWORD="$(cat /run/secrets/db_password)"

# Read WordPress passwords from Docker secret
WP_ADMIN_PASSWORD="$(sed -n '1p' /run/secrets/credentials)"
WP_USER_PASSWORD="$(sed -n '2p' /run/secrets/credentials)"

# Ensure mandatory environment variables and secrets are defined
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_HOST:?DB_HOST is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
: "${WP_TITLE:?WP_TITLE is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"
: "${WP_USER:?WP_USER is required}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL is required}"
: "${WP_ADMIN_PASSWORD:?First line of credentials secret is required}"
: "${WP_USER_PASSWORD:?Second line of credentials secret is required}"

# Ensure the admin username does not contain forbidden words
ADMIN_LC="$(printf "%s" "$WP_ADMIN_USER" | tr '[:upper:]' '[:lower:]')"
if [[ "$ADMIN_LC" == *admin* ]]; then
	echo "ERROR: WP_ADMIN_USER must not contain 'admin'"
	exit 1
fi

# Ensure the WordPress directory exists
mkdir -p "$WP_PATH"

# Wait until MariaDB becomes reachable
echo "Waiting for MariaDB..."
tries=30
until mysqladmin ping -h"${DB_HOST%:*}" -u"${DB_USER}" -p"${DB_PASSWORD}" --silent; do
	tries=$((tries - 1))
	if [ "$tries" -le 0 ]; then
		echo "ERROR: MariaDB did not become ready in time."
		exit 1
	fi
	sleep 2
done

# Download WordPress core files if they do not already exist
if [ ! -f "$WP_PATH/wp-load.php" ]; then
	echo "Downloading WordPress core..."
	wp core download --allow-root --path="$WP_PATH"
fi

# Create wp-config.php if it does not already exist
if [ ! -f "$WP_PATH/wp-config.php" ]; then
	echo "Creating wp-config.php..."
	wp config create \
		--allow-root \
		--path="$WP_PATH" \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$DB_HOST"
fi

# Install WordPress if it has not already been installed
if ! wp core is-installed --allow-root --path="$WP_PATH"; then
	echo "Installing WordPress..."
	wp core install \
		--allow-root \
		--path="$WP_PATH" \
		--url="https://${DOMAIN_NAME}" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL"

	echo "Creating secondary WordPress user..."
	wp user create \
		--allow-root \
		--path="$WP_PATH" \
		"$WP_USER" \
		"$WP_USER_EMAIL" \
		--role=author \
		--user_pass="$WP_USER_PASSWORD"
fi

# Ensure correct ownership for WordPress files
chown -R www-data:www-data "$WP_PATH"

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F