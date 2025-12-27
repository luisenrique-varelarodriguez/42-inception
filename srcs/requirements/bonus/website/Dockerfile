FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./conf/index.html /var/www/html/index.html
COPY ./tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 8081

ENTRYPOINT [ "/bin/bash", "/script.sh" ]
