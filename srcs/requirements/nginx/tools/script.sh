#!/bin/bash
set -e

if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME not set"
    exit 1
fi

# SSL certificate variables
CERT_DIR="/etc/ssl/nginx"
CERT_NAME="sscert.crt"
KEY_NAME="sskey.key"

mkdir -p "$CERT_DIR"

# Generate SSL certificate if it doesn't exist
if [ ! -f "$CERT_DIR/$CERT_NAME" ] || [ ! -f "$CERT_DIR/$KEY_NAME" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERT_DIR/$KEY_NAME" \
        -out "$CERT_DIR/$CERT_NAME" \
        -subj "/C=ES/ST=Madrid/L=Madrid/CN=$DOMAIN_NAME"
fi

# Move NGINX configuration
if [ -f "/default.conf" ]; then
    envsubst '${DOMAIN_NAME}' < /default.conf > /etc/nginx/conf.d/default.conf # Use envsubst to replace DOMAIN_NAME
fi

exec nginx -g "daemon off;"