FROM debian:bullseye-slim

RUN apt-get -y update && \
	apt-get install -y	nginx \
						openssl && \
						apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 443

COPY ./tools/script.sh /
COPY ./conf/default.conf /

RUN chmod +x script.sh

ENTRYPOINT [ "/bin/bash", "script.sh" ]
