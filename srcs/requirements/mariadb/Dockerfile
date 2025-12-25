FROM alpine:3.23.0

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld \
    && chmod 777 /run/mysqld

COPY conf/my.cnf.d/ /etc/my.cnf.d/
COPY tools/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

USER mysql

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/bin/mysqld", "--user=mysql", "--console", "--skip-networking=0", "--bind-address=0.0.0.0"]