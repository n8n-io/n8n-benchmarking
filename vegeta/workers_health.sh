#!/bin/bash

ulimit -n 1048576 # open files

url_postfix="/healthz"

for worker_health_uri in "$@"
do
    echo "Checking worker '$worker_health_uri' health..."
    status=`curl -s -o /dev/null -w "%{http_code}" $worker_health_uri$url_postfix`
    while [ $status -ne 200 ]
    do
        echo "Worker $worker_health_uri not ready yet..."
        sleep 5
        status=`curl -s -o /dev/null -w "%{http_code}" $worker_health_uri$url_postfix`
    done
done

echo "Worker(s) ready"
