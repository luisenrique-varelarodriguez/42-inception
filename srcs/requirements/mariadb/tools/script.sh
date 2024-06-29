#!/bin/bash

# Inicia el servidor MariaDB en segundo plano
mysqld_safe --datadir='/var/lib/mysql' &

# Espera a que MariaDB esté completamente iniciado
echo "Waiting for MariaDB to start..."
until mysqladmin ping &>/dev/null; do
  sleep 5
done
echo "MariaDB is up and running."

# Ejecuta el script de configuración segura de MariaDB
mysql_secure_installation <<EOF
Y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
Y
Y
Y
Y
EOF

# Ejecuta comandos SQL para crear la base de datos y el usuario
mysql <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Detener el servidor MariaDB temporalmente
mysqladmin shutdown

# Inicia el servidor MariaDB en primer plano
exec mysqld_safe --datadir='/var/lib/mysql'
