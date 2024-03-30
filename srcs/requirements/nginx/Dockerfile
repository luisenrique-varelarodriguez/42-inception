# Use a specific version of debian for stability
FROM debian:buster

# Update apk
# Install NGINX and OpenSSL
# Create necesary folders
## Note: we eliminate the /var/lib/apt/lists/* to reduce the size of the image
## because we are not going to install more packages
RUN apt-get update \
    && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/nginx

# Generate a self-signed certificate and private key
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=ES/ST=Madrid/L=Madrid/CN=www.lvarea.42.com"

# Copy the nginx config file and the TLS certs
COPY nginx.conf /etc/nginx/nginx.conf
COPY html/ /usr/share/nginx/html/

# Exposing 443 port (HTTPS)
EXPOSE 443

# Run the nginx server.
## Note: "-g" is an option of nginx command to run global directives
## and "daemon off;" is the directive to run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]