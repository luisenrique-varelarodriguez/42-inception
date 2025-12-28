#!/bin/bash
set -e

if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME not set"
    exit 1
fi

mkdir -p "$CERT_DIR"

# Move NGINX configuration
if [ -f "/default.conf" ]; then
    envsubst '${DOMAIN_NAME}' < /default.conf > /etc/nginx/conf.d/default.conf # Use envsubst to replace DOMAIN_NAME
fi

exec nginx -g "daemon off;"