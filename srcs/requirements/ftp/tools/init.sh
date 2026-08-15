#!/bin/bash

mkdir -p /var/run/vsftpd/empty

useradd -m -d /var/www/html -s /bin/bash ftpuser
chown -R ftpuser:ftpuser /var/www/html

echo "ftpuser:ftp_password" | chpasswd

cat > /etc/vsftpd.conf <<CONF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
local_root=/var/www/html
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
CONF

exec vsftpd /etc/vsftpd.conf
