#!/bin/bash

echo "Running tests..."

request_meta=$(cat /home/ubuntu/fortio/requestMetadata.json)

while IFS= read -r line; do
    vals=($line)
    payload=$(echo ${request_meta} | sed s/workflowid/${vals[0]}/ | sed s/qpsvalue/${vals[1]}/ | sed s/cvalue/${vals[2]}/ | sed s/tvalue/${vals[3]}/ | sed s/timeoutvalue/${vals[4]}/ | sed s/labelsvalue/w${vals[0]}_qps${vals[1]}_c${vals[2]}_t${vals[3]}/)
    echo "Starting test with paylod ${payload}"
    curl -d "${payload}" "localhost:8080/fortio/rest/run?jsonPath=.metadata"
    sleep 10
done < /home/ubuntu/fortio/tests

echo "Results saved in './results/'"


