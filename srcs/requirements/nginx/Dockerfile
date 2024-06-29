FROM debian:bullseye-slim

RUN apt-get -y update && \
	apt-get install -y	nginx \
						openssl && \
	apt-get clean

EXPOSE 443

COPY ./tools/script.sh /
COPY ./conf/default.conf /

RUN chmod +x script.sh

ENTRYPOINT [ "/bin/sh", "script.sh" ]
