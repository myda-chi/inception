#!/bin/bash

set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(sed -n '1p' /run/secrets/credentials)
WP_USER_PASSWORD=$(sed -n '2p' /run/secrets/credentials)


until mysqladmin ping \
    -h mariadb \
    -P 3306 \
    -u "${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    --silent
do
    echo "Waiting for MariaDB..."
    sleep 3
done

echo "MariaDB is ready!"

if [ ! -f "/var/www/html/wp-config.php" ]; then

    wp core download \
        --allow-root \
        --path=/var/www/html

    wp config create \
        --allow-root \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306"

    wp core install \
        --allow-root \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    sed -i "s|<?php|<?php\n\$_SERVER['HTTPS'] = 'on';\n\$_SERVER['SERVER_PORT'] = '${WP_PORT}' ?: '443';|" /var/www/html/wp-config.php

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root \
        --path=/var/www/html
fi


mkdir -p /run/php

exec php-fpm8.2 -F