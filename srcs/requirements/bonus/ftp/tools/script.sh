#!/bin/bash
set -e

if [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ]; then
    echo "Error: FTP_USER and FTP_PASS must be set"
    exit 1
fi

if ! id "$FTP_USER" &>/dev/null; then
    adduser --disabled-password --gecos "" "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    chown -R "$FTP_USER:$FTP_USER" /var/www/html
fi

cat > /etc/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
pasv_address=0.0.0.0
user_sub_token=\$USER
local_root=/var/www/html
EOF

exec /usr/sbin/vsftpd /etc/vsftpd.conf
