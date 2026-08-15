FROM debian:12

RUN apt-get update && \
    apt-get install -y vsftpd && \
    rm -rf /var/lib/apt/lists/*

COPY tools/init.sh /tools/init.sh
RUN chmod +x /tools/init.sh

CMD ["/tools/init.sh"]
