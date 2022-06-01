#!/bin/bash

# path=.
path=/home/ubuntu/vegeta
url_postfix="/healthz"

ulimit -n 1048576 # open files

tested="-1"
echo "Checking workflow health"
while IFS= read -r line; do
    vals=($line)
    if [ "$tested" == "${vals[0]}" ]; then
        echo "skip"
    else
        echo "Checking workflow - ${vals[0]}"
        status=`curl -s -o /dev/null -w "%{http_code}" $1/webhook/workflow-${vals[0]}`
        while [ $status -ne 200 ]
        do
            echo "Workflow ${vals[0]} not ready yet..."
            sleep 5
            status=`curl -s -o /dev/null -w "%{http_code}" $1/webhook/workflow-${vals[0]}`
        done
        tested=${vals[0]}
    fi
done < $path/tests

echo "Workflow(s) ready"
