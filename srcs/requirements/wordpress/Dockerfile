# Use Debian 12 as the base image
FROM debian:12

# Update package lists and install the required software for WordPress while avoiding unnecessary recommended packages
RUN apt-get update && apt-get install -y --no-install-recommends \
	php8.2-fpm \        # PHP FastCGI Process Manager that executes PHP scripts for nginx via FastCGI
	php8.2-mysql \      # PHP extension enabling WordPress to communicate with the MariaDB database
	php8.2-curl \       # PHP extension providing HTTP client functionality used by WordPress and plugins
	php8.2-gd \         # PHP extension used for image processing such as resizing and thumbnail generation
	php8.2-mbstring \   # PHP extension required for proper UTF-8 and multibyte string handling
	php8.2-xml \        # PHP extension providing XML parsing used for feeds and APIs
	php8.2-zip \        # PHP extension allowing installation of plugins and themes distributed as ZIP archives
	curl \              # Command-line tool used to download files such as wp-cli
	ca-certificates \   # Provides trusted SSL certificates for secure HTTPS downloads
	mariadb-client \    # MariaDB client useful for testing and debugging database connectivity
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*   # Remove cached package lists to reduce image size

# Download the WordPress CLI tool which allows automated installation and configuration of WordPress
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp

# Set the working directory where WordPress files will be installed and shared with nginx via a Docker volume
WORKDIR /var/www/html

# Copy the custom PHP-FPM pool configuration that defines how PHP processes FastCGI requests
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy the setup script responsible for configuring WordPress and launching PHP-FPM
COPY tools/setup.sh /usr/local/bin/setup.sh

# Ensure the setup script is executable
RUN chmod +x /usr/local/bin/setup.sh

# Expose the FastCGI port used internally by nginx to communicate with PHP-FPM
EXPOSE 9000

# Define the entrypoint script that initializes WordPress and starts PHP-FPM
ENTRYPOINT ["/usr/local/bin/setup.sh"]