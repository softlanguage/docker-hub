set -e
cwd=$(realpath $(dirname $0))
echo "deploy_work_dir = $cwd"

# repository = https://git.local/org/repo.git#branch:src/folder
git_repository=https://mygit.lan:8443/hcrm/demo.git

alias dockerman='docker -c pod01.dev'

BUILD_NUMBER=${BUILD_NUMBER:-9999}
BUILD_TAG=${BUILD_TAG:-"dev-demo-$BUILD_NUMBER"}
BUILD_TAG=$(echo "$BUILD_TAG" | sed 's/^jenkins-//')
IMAGE_NAME="img.local/${JOB_NAME:-dev/demo}:$BUILD_NUMBER"

dockerman pull docker.io/python:3.10-slim-bullseye

# apt install docker-buildx on jenkins and pod01.dev@remote
dockerman build --cpuset-cpus=0 -m 2g --force-rm --network host \
  -t $IMAGE_NAME -f $cwd/../npm/Dockerfile $git_repository

dockerman image ls $IMAGE_NAME

BUILD_TAG=$BUILD_TAG IMAGE_NAME=$IMAGE_NAME \
dockerman stack deploy -c $cwd/compose.yaml ns_dev

# inline compose:
<<///compose
version: '3.7'
networks:
  default:
    name: ns_dev
    external: true
services:
  api-python:
    # docker.io/traefik/whoami:v1.10
    image: ${IMAGE_NAME}
    hostname: ${BUILD_TAG}
    deploy:
      mode: replicated
      replicas: 1
      resources:
        limits:
          cpus: '1'
          memory: 512M
///compose
