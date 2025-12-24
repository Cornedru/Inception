FROM alpine:3.19
# checker: Ensure that every container is built from the penultimate stable version of Alpine/Debian.

RUN apk update && apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl

# Génération du certificat auto-signé (validité 1 an)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=GrandEst/L=Mulhouse/O=42/OU=42/CN=ndehmej.42.fr/UID=ndehmej"

COPY conf/nginx.conf /etc/nginx/nginx.conf

# Logs vers stdout/stderr pour Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["nginx", "-g", "daemon off;"]