FROM debian:12

RUN apt-get update && \
    apt-get install -y php-cli php-mysql curl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www

RUN curl -L https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.php \
    -o /var/www/adminer.php

RUN printf '<?php require "/var/www/adminer.php"; ?>' > /var/www/index.php

WORKDIR /var/www

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www"]
