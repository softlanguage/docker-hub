#!/bin/bash
set -e
TZ=UTC-8
echo "----- wait mysql start... $(date) ----"

times=0
while [ $times -lt 3 ]; # true;
do
    if [[ -e /var/run/mysqld/mysqld.sock ]];
    then
        echo ">> mysql start success $(date)"
        sleep 3
        exit 0;
    fi
    times=`expr $times + 1`
    sleep 3;
done

echo "Warning: mysql start too long $(date)"
exit 1
