FROM debian:bullseye-slim

RUN apt-get -y update && \
	apt-get install -y	php-fpm \
						php-mysql \
						curl && \
	apt-get clean

EXPOSE 8080:8080

COPY ./tools/script.sh /

RUN chmod +x script.sh

ENTRYPOINT [ "/bin/sh", "script.sh" ]
