FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysqli \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./tools/script.sh /script.sh

RUN chmod +x /script.sh && \
    mkdir -p /var/www/html /run/php

EXPOSE 8080

ENTRYPOINT [ "/bin/bash", "/script.sh" ]
