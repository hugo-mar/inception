#!/bin/bash

# Exit immediately if any command fails
set -e

# Ensure the required DOMAIN_NAME environment variable is defined
: "${DOMAIN_NAME:?DOMAIN_NAME is required}"

# Define paths for SSL certificate storage
SSL_DIR="/etc/nginx/ssl"
SSL_KEY="${SSL_DIR}/inception.key"
SSL_CERT="${SSL_DIR}/inception.crt"

# Ensure required directories exist:
# - SSL directory for certificates
# - Nginx runtime directory (PID, sockets, etc.)
mkdir -p "$SSL_DIR"
mkdir -p /run/nginx

# Check if SSL certificate and key already exist
# If not, generate a self-signed TLS certificate for the specified domain
if [ ! -f "$SSL_KEY" ] || [ ! -f "$SSL_CERT" ]; then
	echo "Generating self-signed TLS certificate for ${DOMAIN_NAME}..."

	# Generate a self-signed certificate using OpenSSL:
	# - 4096-bit RSA key
	# - Valid for 365 days
	# - No passphrase (-nodes)
	# - Subject contains certificate metadata
	openssl req -x509 -nodes -newkey rsa:4096 \
		-keyout "$SSL_KEY" \
		-out "$SSL_CERT" \
		-days 365 \
		-subj "/C=PT/ST=Lisboa/L=Lisboa/O=42/OU=Inception/CN=${DOMAIN_NAME}"


	# Set secure permissions:
	# - Private key readable only by owner
	# - Certificate readable by others
	chmod 600 "$SSL_KEY"
	chmod 644 "$SSL_CERT"
else
	echo "TLS certificate already exists. Skipping generation."
fi

# Validate nginx configuration before starting
# This prevents runtime failures due to misconfiguration
echo "Testing nginx configuration..."
nginx -t

# Start nginx in the foreground (required for Docker containers)
# This replaces the shell process (PID 1)
echo "Starting nginx..."
exec nginx -g "daemon off;"