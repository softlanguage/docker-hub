set -e

endpoints=http://172.17.0.13:2379,http://172.17.0.14:2379,http://172.17.0.3:2379

docker exec -it -e endpoints=$endpoints etcd4dev etcdctl \
    --user=health:health endpoint status -w=table --endpoints=$endpoints
