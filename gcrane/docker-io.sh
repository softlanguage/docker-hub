#!/bin/bash
set -e

# mysql
crane copy docker.io/mysql:lts docker.io/softlang/mysql:8.4-lts
crane copy docker.io/gitea/gitea:1.21.11 docker.io/softlang/gitea:1.21.11
crane copy docker.io/gitea/gitea:1.22.6 docker.io/softlang/gitea:1.22.6
crane copy docker.io/gitea/gitea:1.23.8 docker.io/softlang/gitea:1.23.8
