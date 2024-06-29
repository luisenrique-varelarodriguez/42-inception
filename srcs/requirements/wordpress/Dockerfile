FROM debian:bullseye-slim

RUN apt-get -y update && \
	apt-get install -y	php-fpm=2:7.4+76 \
						php-mysql=2:7.4+76 \
						curl=7.74.0-1.3+deb11u11

EXPOSE 8080:8080

COPY ./tools/script.sh /

RUN chmod +x script.sh

ENTRYPOINT [ "/bin/sh", "script.sh" ]
