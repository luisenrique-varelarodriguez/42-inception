#!/bin/bash

# Start the MariaDB service
service mariadb start

# Wait for MariaDB to start up completely
echo "Waiting for MariaDB to start..."
until mysqladmin ping &>/dev/null; do
  sleep 1
done
echo "MariaDB is up and running."

# Run the mysql_secure_installation script to secure the MariaDB installation
mysql_secure_installation <<EOF

Y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
Y
Y
Y
Y
EOF

# Execute SQL commands to create the database and user
mysql <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Restart the MariaDB service to apply the new configuration
service mariadb restart

# Start the MariaDB server daemon
exec mariadbd
