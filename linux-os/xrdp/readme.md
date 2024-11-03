
- guide

```sh
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
supervisorctl reread
supervisorctl update

cat <<//EOF
# install nginx
apt install nginx libnginx-mod-stream

# supervisorctl
[program:nginx]
command=nginx -c /etc/nginx/nginx.conf  -g 'daemon off;'
user=root
autorestart=true
priority=400

# nginx config
stream{
    server{
        listen 3306;
        proxy_pass 10.0.16.4:3306;
        proxy_timeout 188m;
    }
}

useradd -m -s /bin/bash siri
usermod -aG sudo siri
192.168.100.201:3389

# start 
/usr/share/sangfor/EasyConnect/resources/bin/EasyMonitor restart #stop

//EOF
```