#!/bin/bash

# Generates a self-signed certificate and private key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=ES/ST=Madrid/L=Madrid/CN=www.lvarea.42.com"

nginx -g "daemon off;"