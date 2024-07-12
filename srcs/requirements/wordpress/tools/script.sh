#!/bin/bash

# Variables
WP_CONFIG_FILE=/var/www/html/wp-config.php

# Download WP-CLI
curl -o wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

sleep 5

# Make WP-CLI executable and move it to a global location
chmod +x wp && mv wp /usr/local/bin/wp

# Create necessary directories for nginx and wordpress
mkdir -p /var/www/html

# Move to the html directory and clean it
cd /var/www/html && rm -rf *

# Download WordPress core files
wp core download --allow-root

sleep 5

wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_USER_PASSWORD --dbhost=$DB_HOST --allow-root

# Wait for wp-config.php to be available
while [ ! -f $WP_CONFIG_FILE ]; do
  sleep 1
done

# Generate unique keys and salts
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

# Replace placeholder lines with the generated salts
sed -i "/AUTH_KEY/c\\$SALTS" $WP_CONFIG_FILE

# Install WordPress
wp core install --url=$DOMAIN_NAME --title="$PROJECT" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$LOGIN@inception.com --allow-root

# Create a new WordPress user with author role
wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" --user_pass="${WORDPRESS_USER_PASSWORD}" --role=author --allow-root

# Adjust PHP-FPM configuration to listen on port 9000 instead of a socket
sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf

# Create the PHP-FPM run directory
mkdir /run/php

# Start PHP-FPM
exec /usr/sbin/php-fpm7.4 -F