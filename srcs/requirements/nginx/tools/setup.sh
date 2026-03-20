#!/bin/bash
set -e

: "${DOMAIN_NAME:?DOMAIN_NAME is required}"

SSL_DIR="/etc/nginx/ssl"
SSL_KEY="${SSL_DIR}/inception.key"
SSL_CERT="${SSL_DIR}/inception.crt"

mkdir -p "$SSL_DIR"
mkdir -p /run/nginx

if [ ! -f "$SSL_KEY" ] || [ ! -f "$SSL_CERT" ]; then
	echo "Generating self-signed TLS certificate for ${DOMAIN_NAME}..."

	openssl req -x509 -nodes -newkey rsa:4096 \
		-keyout "$SSL_KEY" \
		-out "$SSL_CERT" \
		-days 365 \
		-subj "/C=PT/ST=Lisboa/L=Lisboa/O=42/OU=Inception/CN=${DOMAIN_NAME}"

	chmod 600 "$SSL_KEY"
	chmod 644 "$SSL_CERT"
else
	echo "TLS certificate already exists. Skipping generation."
fi

echo "Testing nginx configuration..."
nginx -t

echo "Starting nginx..."
exec nginx -g "daemon off;"