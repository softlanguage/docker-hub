#!/bin/sh

apk update && apk upgrade
apk add --no-cache ca-certificates nginx openssh screen sudo
rm -rf /var/cache/apk/* /tmp/*
update-ca-certificates 2>/dev/null || true

sed -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' -i /etc/sudoers
passwd -d root

adduser -D -s /bin/ash ${P_USER}
addgroup ${P_USER} wheel
mkdir -p /home/${P_USER}/.ssh/
chown -R ${P_USER}:${P_USER} /home/${P_USER}
ssh-keygen -A

mkdir -p /run/nginx
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

echo "Starting nginx..."
# /usr/sbin/nginx

echo "Starting sshd..."
# /usr/sbin/sshd -D
