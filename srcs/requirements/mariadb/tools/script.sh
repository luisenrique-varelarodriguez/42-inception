#!/bin/bash

# Variables
DATA_DIR=/var/lib/mysql

# Starts the MariaDB server in the background
mysqld_safe --datadir='/var/lib/mysql' &

# Waits for MariaDB to be fully started
echo "Waiting for MariaDB to start..."
until mysqladmin ping &>/dev/null; do
  sleep 5
done
echo "MariaDB is up and running."

# Runs the MariaDB secure installation script
mysql_secure_installation <<EOF

Y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
Y
Y
Y
Y
EOF

# Runs SQL commands to create the database and user
mysql <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Temporarily stops the MariaDB server
mysqladmin shutdown

# Starts the MariaDB server in the foreground
exec mysqld_safe --datadir='/var/lib/mysql'
