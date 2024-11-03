# ubuntu:bionic 
# docker build --force-rm -m 2g -t softlang/ubuntu:18.04-xrdp-xfce .
FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -yy && apt install -y \
    nginx libnginx-mod-stream \
    sudo \
    supervisor \
    uuid-runtime \
    telnet \
    lsof \
    vim \
    wget \
    xauth \
    xfce4 \
    xfce4-clipman-plugin \
    xfce4-cpugraph-plugin \
    xfce4-netload-plugin \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-terminal \
    xfce4-xkb-plugin \
    xorgxrdp \
    xprintidle \
    xrdp \
    && apt-get remove -yy xscreensaver \
    && apt autoremove -yy \
    && rm -rf /var/cache/apt /var/lib/apt/lists

COPY supervisor.d/* /etc/supervisor/conf.d/

CMD /usr/bin/printf '\n** xrdp-user need password **\n\n' && exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
