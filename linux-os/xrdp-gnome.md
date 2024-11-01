- xrdp + gnome

```sh
docker build -t softlang/ubuntu-gnome-xrdp --build-arg --build-arg PASS=ubunt2 .
docker run -d -p 3389:3389 --name xrdp-gnome softlang/ubuntu-gnome-xrdp
docker exec -it xrdp-gnome bash
gnome-terminal

app_name=xrdp-gnome.local
pod_opts="-m 2gb --memory-swap=-1 --ip=192.168.201.201 --network apps"
docker run -itd --name $app_name -h $app_name $pod_opts $pod_envs ubuntu:noble

# selenium/standalone-chrome:129.0 -e SE_SCREEN_WIDTH=1280 -e SE_SCREEN_HEIGHT=960 -e VNC_NO_PASSWORD=1
# /usr/share/sangfor/EasyConnect/EasyConnect

cat <<///comments
apt-get install -y gnome-session gnome-terminal
apt-get install -y ubuntu-gnome-desktop
apt-get install -y xrdp
apt install libgtk2.0-0 # for easyconnect

service xrdp start
systemctl enable xrdp
useradd -m -s /bin/bash siri
usermod -aG sudo siri
///comments
```

```Dockerfile
FROM ubuntu:noble
ARG USER=ubuntu
ARG PASS=ubunt2

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
        apt-get install -y ubuntu-desktop-minimal dbus-x11 xrdp sudo; && \
    apt-get install -y openssh-server; \
    apt-get autoremove --purge; \
    apt-get clean; \
    rm /run/reboot-required*
RUN useradd -s /bin/bash -m $USER -p $(openssl passwd "$PASS"); \
    usermod -aG sudo $USER; \
    adduser xrdp ssl-cert;

CMD rm -f /var/run/xrdp/xrdp*.pid >/dev/null 2>&1; \
    service dbus restart >/dev/null 2>&1; \
    /usr/lib/systemd/systemd-logind >/dev/null 2>&1 & \
    [ -f /usr/sbin/sshd ] && /usr/sbin/sshd; \
    xrdp-sesman --config /etc/xrdp/sesman.ini; \
    xrdp --nodaemon --config /etc/xrdp/xrdp.ini

```