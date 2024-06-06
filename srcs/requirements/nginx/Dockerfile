FROM debian:buster

RUN apt -y update && \
	apt install -y enginx openssl

COPY ./tools/script.sh /
COPY nginx.conf /etc/nginx/nginx.conf

CMD [ "/script.sh" ]