#!/bin/bash
set -e

if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || \
   [ -z "$MYSQL_USER_PASSWORD" ] || [ -z "$DB_HOST" ] || \
   [ -z "$DOMAIN_NAME" ] || [ -z "$WP_ADMIN_USER" ] || \
   [ -z "$WP_ADMIN_PASS" ]; then
    echo "Error: Missing required environment variables"
    exit 1
fi

WP_DIR="/var/www/html"
# Marker file to track if WordPress is already installed (prevents re-installation on restart)
MARKER="$WP_DIR/.initialized"

mkdir -p "$WP_DIR" /run/php

# Give MariaDB time to fully start
sleep 15

# Download WP-CLI if not present
if [ ! -f /usr/local/bin/wp ]; then
    curl -sS -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x /usr/local/bin/wp
fi

cd "$WP_DIR"

# Check if WordPress is already installed
if [ -f "$MARKER" ] && wp core is-installed --allow-root 2>/dev/null; then
    echo "WordPress already installed"
else
    # Clean and download WordPress
    rm -rf "$WP_DIR"/*
    wp core download --allow-root
    
    # Create wp-config
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_USER_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root
    
    # Wait for database
    until wp db check --allow-root 2>/dev/null; do
        sleep 3
    done
    
    # Install WordPress
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="${PROJECT:-Inception}" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="${LOGIN:-admin}@inception.com" \
        --skip-email \
        --allow-root
    
    # Create additional user if specified
    if [ -n "$WORDPRESS_USER" ] && [ -n "$WORDPRESS_USER_EMAIL" ] && [ -n "$WORDPRESS_USER_PASSWORD" ]; then
        wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
            --user_pass="$WORDPRESS_USER_PASSWORD" \
            --role=author \
            --allow-root 2>/dev/null || true
    fi
    
    touch "$MARKER"
fi

# Configure PHP-FPM
sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf
chown -R www-data:www-data "$WP_DIR"

exec /usr/sbin/php-fpm7.4 -F