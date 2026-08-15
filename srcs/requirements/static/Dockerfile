FROM debian:12

RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

COPY conf/index.html /var/www/html/index.html

RUN rm -f /etc/nginx/sites-enabled/default

COPY conf/static.conf /etc/nginx/conf.d/static.conf

CMD ["nginx", "-g", "daemon off;"]
