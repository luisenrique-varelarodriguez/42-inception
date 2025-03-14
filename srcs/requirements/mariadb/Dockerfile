FROM debian:bullseye-slim

RUN apt-get -y update && \
    apt-get install -y mariadb-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 3306

COPY ./tools/script.sh /
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /script.sh

ENTRYPOINT [ "/bin/bash", "/script.sh" ]
