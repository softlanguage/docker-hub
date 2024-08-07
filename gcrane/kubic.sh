#!/bin/bash
set -e

platform="--platform linux/amd64"

# docker library
images=(traefik:v2.11
registry:2.8.3
haproxy:2.8.9-alpine
busybox:glibc
alpine:3.18
)
for i in "${images[@]}"; do
sh -c "crane copy docker.io/$i docker.io/softlang/$i $platform"
done

# registry.k8s.io
crane copy registry.k8s.io/metrics-server/metrics-server:v0.7.1 docker.io/softlang/metrics-server:v0.7.1 $platform

function config_k8s_images(){
    # kubeadm config images list # to list all k8s images
    images=($(kubeadm config images list))
    for i in "${images[@]}"; do
        #img=$(printf "$i" | sed 's+registry.k8s.io++g')
        img=${i/registry.k8s.io/""}
        crane copy registry.k8s.io$img registry.bug.fyi$img $platform
    done
}
#config_k8s_images
