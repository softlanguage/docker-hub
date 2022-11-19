#### run caddy as service with systemctl

```shell
# install
dnf install caddy

# caddy validate
caddy validate --config /etc/caddy/Caddyfile
caddy validate # need-pre: cd /etc/caddy

# reload caddy
systemctl reload caddy
```