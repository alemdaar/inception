#!/bin/bash

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld


if [ ! -f "/var/lib/mysql/.initialized" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe --skip-networking &

    until mysqladmin ping --silent; do
        sleep 1
    done

    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

    touch /var/lib/mysql/.initialized

fi

exec mariadbd --user=mysql
