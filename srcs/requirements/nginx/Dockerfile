FROM debian:bullseye-slim

# Install nginx and openssl
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        openssl \
        gettext-base \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy configuration and scripts
COPY ./conf/default.conf /
COPY ./tools/script.sh /

# Set permissions
RUN chmod +x /script.sh

EXPOSE 443

ENTRYPOINT [ "/bin/bash", "/script.sh" ]
