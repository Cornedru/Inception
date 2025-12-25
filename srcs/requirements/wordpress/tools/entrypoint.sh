#!/bin/sh

while ! nc -z mariadb 3306; do
  sleep 1
done

DB_PWD=$(cat /run/secrets/db_password)
WP_ADMIN_PWD=$(cat /run/secrets/wp_admin_password)
WP_USER_PWD=$(cat /run/secrets/wp_user_pwd)

if [ ! -f wp-config.php ]; then
    wp core download --allow-root

    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$DB_PWD \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --url="$DOMAIN_NAME" \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PWD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root

    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PWD --allow-root
	# wp option update home "https://${DOMAIN_NAME}:4443" --allow-root
	# wp option update siteurl "https://${DOMAIN_NAME}:4443" --allow-root
fi

exec "$@"