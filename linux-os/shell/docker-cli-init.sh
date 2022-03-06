set -e
echo ---------- Sun Mar  6 08:12:36 UTC 2022 ----------
echo user=devops
echo pass=dev0ps
echo 'docker run -v /var/run/docker.sock:/var/run/docker.sock:ro -e DOCKER_GROUP_ID=0 -e DOCKER_GROUP_NAME=nogroup'

if ! grep -q ${DOCKER_GROUP_NAME} /etc/group
then
addgroup -g ${DOCKER_GROUP_ID} ${DOCKER_GROUP_NAME}
adduser devops ${DOCKER_GROUP_NAME}
fi

/usr/sbin/sshd -D