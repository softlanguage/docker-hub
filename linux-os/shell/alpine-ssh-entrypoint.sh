#!/bin/sh

apk update && apk upgrade
apk add --no-cache ca-certificates nginx openssh screen sudo
rm -rf /var/cache/apk/* /tmp/*
update-ca-certificates 2>/dev/null || true

sed -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' -i /etc/sudoers
passwd -d root

adduser -D -s /bin/ash ${GITHUB_USER}
passwd -u ${GITHUB_USER}
addgroup ${GITHUB_USER} wheel
mkdir -p /home/${GITHUB_USER}/.ssh/
wget -q -O /home/${GITHUB_USER}/.ssh/authorized_keys https://github.com/${GITHUB_USER}.keys
chown -R ${GITHUB_USER}:${GITHUB_USER} /home/${GITHUB_USER}
ssh-keygen -A

mkdir -p /run/nginx
sed -i 's|\treturn 404|\tproxy_set_header X-Real-IP $remote_addr;\n\t\tproxy_set_header X-Forwarded-Proto https;\n\t\tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\t\tproxy_set_header Host $http_host;\n\t\tproxy_redirect http:// https://;\n\t\tproxy_pass '${PROXY_PASS}'|g' /etc/nginx/conf.d/default.conf
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

echo "Starting nginx..."
/usr/sbin/nginx

echo "Starting sshd..."
/usr/sbin/sshd -D
