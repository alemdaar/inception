FROM debian:12

RUN apt-get update && \
    apt-get install -y \
    php-fpm \
    php-cli \
    php-mysql \
    php-curl \
    php-xml \
    php-mbstring \
    php-zip \
    mariadb-client \
    curl
RUN sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /run/php



COPY ./tools/init.sh /tools/init.sh

RUN chmod +x /tools/init.sh

CMD ["bash", "/tools/init.sh"]
