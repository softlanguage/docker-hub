exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
#exec /usr/bin/tail -f /dev/null

<<'///comments'
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
supervisorctl reread
supervisorctl update

apt install -y nginx libnginx-mod-stream \
  sudo \
  supervisor \
  uuid-runtime \
  vim \
  vlc \
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
  xrdp 


///comments
