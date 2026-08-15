FROM debian:12

RUN apt-get update && \
    apt-get install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/init.sh /tools/init.sh

RUN chmod +x /tools/init.sh

CMD ["bash", "/tools/init.sh"]
