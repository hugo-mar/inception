# Use Debian 12 as the base image
FROM debian:12

# Update package lists and install the required software for nginx with TLS support
	# nginx - Web server that will serve the WordPress site over HTTPS
	# openssl - Used to generate the self-signed TLS certificate and private key
RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx \
	openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Create the directory where nginx stores TLS certificates and private keys
RUN mkdir -p /etc/nginx/ssl

# Copy the custom nginx configuration file
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy the setup script responsible for generating the TLS certificate and starting nginx
COPY tools/setup.sh /usr/local/bin/setup.sh

# Ensure the setup script is executable
RUN chmod +x /usr/local/bin/setup.sh

# Expose HTTPS port
EXPOSE 443

# Define the entrypoint script that generates TLS files and starts nginx in foreground
ENTRYPOINT ["/usr/local/bin/setup.sh"]