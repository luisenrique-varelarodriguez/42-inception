FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./tools/script.sh /script.sh

RUN chmod +x /script.sh && \
    mkdir -p /var/run/vsftpd/empty

EXPOSE 21 21100-21110

ENTRYPOINT [ "/bin/bash", "/script.sh" ]
