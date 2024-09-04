set -e

docker run -d --name gpdb7rhel8.local -h gpdb7rhel8.local -e TZ=Asia/Shanghai \
    -p 5677:5677 --network apps -w /mpp \
    -v ./mpp/dist:/mpp/dist \
    -v ./mpp/pyops:/mpp/gpadmin/pyops \
    -v ./mpp/conf.d:/mpp/gpadmin/conf.d \
    --add-host "gp7m1.local:127.0.0.1" \
    --add-host "gp7s1.local:127.0.0.1" \
    --add-host "gp7s2.local:127.0.0.1" \
    --shm-size 1gb -m 4gb --memory-swap 4gb --kernel-memory 1gb \
    --cpuset-cpus 0,1 \
    localhost/gpdb7:rhel8

# --kernel-memory 1gb, do not effective of buff/cache
# --shm-size 1gb -m 4gb --memory-swap 4gb, are enough