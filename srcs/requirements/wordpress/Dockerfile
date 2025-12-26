FROM debian:bullseye-slim

# Install PHP-FPM and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
        curl \
        default-mysql-client \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy scripts
COPY ./tools/script.sh /script.sh

# Set permissions and create directories
RUN chmod +x /script.sh && \
    mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/bin/bash", "/script.sh" ]
