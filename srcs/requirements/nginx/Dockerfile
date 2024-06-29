FROM debian:bullseye-slim

RUN apt-get -y update && \
	apt-get install -y	nginx=1.18.0-6.1+deb11u3 \
						openssl=1.1.1n-0+deb11u5 && \
						apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 443

COPY ./tools/script.sh /
COPY ./conf/default.conf /

RUN chmod +x script.sh

ENTRYPOINT [ "/bin/sh", "script.sh" ]
