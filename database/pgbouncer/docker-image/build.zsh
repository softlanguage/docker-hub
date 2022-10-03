#!/bin/bash
set -e
docker build --network host --force-rm -f Dockerfile -t softlang/pgbouncer:v1.17.0 .
