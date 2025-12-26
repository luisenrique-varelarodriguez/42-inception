#!/bin/bash
set -e

if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || \
   [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_USER_PASSWORD" ]; then
  echo "Error: Missing required environment variables"
  exit 1
fi

DATA_DIR="/var/lib/mysql"
MARKER="$DATA_DIR/.initialized"

# If already initialized, just start
if [ -f "$MARKER" ]; then
  exec mysqld_safe --datadir="$DATA_DIR"
fi

# First time initialization
mysqld_safe --datadir="$DATA_DIR" &

# Wait for MariaDB to start (socket)
until mysqladmin --protocol=socket ping --silent &>/dev/null; do
  sleep 1
done

# Bootstrap users/dbs non-interactively over the local socket
mysql --protocol=socket -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

touch "$MARKER"

# Restart MariaDB in the foreground
mysqladmin --protocol=socket -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

exec mysqld_safe --datadir="$DATA_DIR"
