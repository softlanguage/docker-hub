# crontab -l
# 16 3 * * * /opt/containerd/etcd.d/bak_cron.sh
# cron logged by rsyslog, config: /etc/rsyslog.conf `#cron*`, 'systemctl restart rsyslog.service'
set -e
bak_today=$(date +%Y%m%d-%H%M%S)
docker exec etcd4dev ash -c "etcdctl --user health:health snapshot save /etcd_data/member/_bak/bak${bak_today}.bak" \
	|| echo "${bak_today}, failed for backup" >> /opt/containerd/etcd.d/error.log
echo ">>prune old *.bak files"

docker exec etcd4dev ash -c "find /etcd_data/member/_bak/ -name '*.bak' -type f -mtime +15 -print -exec rm -rf {} \;" \
	|| echo "${bak_today}, failed for prune old .bak files" >> /opt/containerd/etcd.d/error.log

echo ">>finish."

## ------ copy backup.db to every node ----
# 1. run at node0 container
etcdctl snapshot restore bak20220331-001101.bak \
  --name etcd0 \
  --initial-cluster "etcd0=http://172.17.0.3:2380,etcd1=http://172.17.0.13:2380,etcd2=http://172.17.0.14:2380" \
  --initial-cluster-token etcd4hrisvip4dev \
  --initial-advertise-peer-urls http://172.17.0.3:2380

# 2. run at node1 container
etcdctl snapshot restore bak20220331-001101.bak \
  --name etcd1 \
  --initial-cluster "etcd0=http://172.17.0.3:2380,etcd1=http://172.17.0.13:2380,etcd2=http://172.17.0.14:2380" \
  --initial-cluster-token etcd4hrisvip4dev \
  --initial-advertise-peer-urls http://172.17.0.13:2380

# 3. run at node2 container
etcdctl snapshot restore bak20220331-001101.bak \
  --name etcd2 \
  --initial-cluster "etcd0=http://172.17.0.3:2380,etcd1=http://172.17.0.13:2380,etcd2=http://172.17.0.14:2380" \
  --initial-cluster-token etcd4hrisvip4dev \
  --initial-advertise-peer-urls http://172.17.0.14:2380

## -- run at host server
# >> docker compose -p host-etcd down
# >> rm old member/*
# >> mv etcd?/member/* /etcd_data/member/
# >> xcompose -p host-etcd -f compose.yaml up -d
# 