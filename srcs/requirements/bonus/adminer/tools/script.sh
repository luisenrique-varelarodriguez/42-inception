#!/bin/bash
set -e

ADMINER_DIR="/var/www/html"

if [ ! -f "$ADMINER_DIR/index.php" ]; then
    curl -fsSL "https://www.adminer.org/latest.php" -o "$ADMINER_DIR/index.php"
    chown -R www-data:www-data "$ADMINER_DIR"
fi

cd "$ADMINER_DIR"

exec php -S 0.0.0.0:8080 -t "$ADMINER_DIR"
