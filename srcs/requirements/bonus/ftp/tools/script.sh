#!/bin/bash
set -e

# Read secrets from Docker secrets files
if [ -f /run/secrets/ftp_user ]; then
  FTP_USER=$(cat /run/secrets/ftp_user)
fi

if [ -f /run/secrets/ftp_pass ]; then
  FTP_PASS=$(cat /run/secrets/ftp_pass)
fi

if [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ]; then
    echo "Error: FTP_USER and FTP_PASS must be set"
    exit 1
fi


if ! id "$FTP_USER" &>/dev/null; then
  adduser --disabled-password --gecos "" "$FTP_USER"
  echo "$FTP_USER:$FTP_PASS" | chpasswd
  chown -R "$FTP_USER:$FTP_USER" /var/www/html
fi

exec /usr/sbin/vsftpd /etc/vsftpd.conf
