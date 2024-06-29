#!/bin/bash

# Variables
DAYS_VALID=365
CERT_DIR="/etc/ssl/nginx"
CERT_NAME="sscert.crt"
KEY_NAME="sskey.key"
SUBJECT="/C=ES/ST=Madrid/L=Madrid/CN=$DOMAIN_NAME"

# Creates directories if they don't exists
mkdir -p $CERT_DIR

# Check if the certificate and key already exist
if [ -f "$CERT_DIR/$CERT_NAME" ] && [ -f "$CERT_DIR/$KEY_NAME" ]; then
    echo "Certificate and private key already exist. Skipping generation."
else
    # Generates the certificate and the private key
    openssl req -x509 -nodes -days $DAYS_VALID -newkey rsa:2048 -keyout $CERT_DIR/$KEY_NAME -out $CERT_DIR/$CERT_NAME -subj "$SUBJECT"

    # Verify if the generation was successful
    if [ $? -eq 0 ]; then
        echo "Certificate and private key successfully generated."
        echo "Certificate: $CERT_DIR/$CERT_NAME"
        echo "Private key: $CERT_DIR/$KEY_NAME"
    else
        echo "Error generating the certificate and private key." >&2
        exit 1
    fi
fi

# Move the default.conf file to the correct location
if [ -f "/default.conf" ]; then
    mv /default.conf /etc/nginx/conf.d/default.conf
else
    echo "default.conf file not found. Exiting." >&2
    exit 1
fi

exec nginx -g "daemon off;"