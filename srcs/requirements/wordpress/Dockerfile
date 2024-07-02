FROM debian:bullseye-slim

RUN apt-get -y update && \
    apt-get install -y  php-fpm \
                        php-mysql \
                        curl

EXPOSE 8080

COPY ./tools/script.sh /

RUN chmod +x /script.sh

ENTRYPOINT [ "/bin/bash", "/script.sh" ]
