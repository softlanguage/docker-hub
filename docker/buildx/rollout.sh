set -e
cwd=$(realpath $(dirname $0))
echo "deploy_work_dir = $cwd"

alias dockerman='docker -c pod01.dev'

dockerman pull docker.io/python:3.10-slim-bullseye
image_tag=${image_tag:-"local/dev/demo:v1"}

opts="--cpuset-cpus=0 -m 2g --force-rm -t $image_tag --network host"
dockerman build $opts -f $cwd/Dockerfile \
    https://mygit.bur.ink:8443/sample/demo.git

dockerman image ls $image_tag

dockerman stack deploy -c $cwd/compose.yaml ns_dev
