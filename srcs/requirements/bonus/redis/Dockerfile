FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 6379

ENTRYPOINT [ "/bin/bash", "/script.sh" ]
