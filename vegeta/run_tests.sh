#!/bin/bash

# path=.
path=/home/ubuntu/vegeta

echo "Test run started."

echo "Waiting for workers.."

ind=0

while IFS= read -r line; do
    $path/workers_health.sh ${@:2}
    vals=($line)
    echo "Running test: workflow-${vals[0]} rate:${vals[1]}..."
    echo "GET http://$2/webhook/workflow-${vals[0]}" | /home/ubuntu/vegeta/vegeta attack -duration=${vals[2]}s -rate ${vals[1]} | tee /home/ubuntu/vegeta/results/result_${vals[0]}_$ind.bin | /home/ubuntu/vegeta/vegeta report -type json -output /home/ubuntu/vegeta/results/report_w${vals[0]}_$ind.json
    ind=$((ind+1))
    echo "test: workflow-${vals[0]} rate:${vals[1]} completed. Taking a power nap..."
    sleep $1
done < $path/tests

echo "Results saved in './results/'"
