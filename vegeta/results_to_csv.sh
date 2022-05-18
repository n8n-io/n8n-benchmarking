#!/bin/bash

path=~/vegeta
# path=.

for wf in {1..2}
do
   echo "Generating csv for w${wf}"
   jq -s --arg WF "$wf" --arg MODE "$1" --arg INSTANCE "$2" 'map({Workflow: $WF, Mode: $MODE, Instance: $INSTANCE, Rate: .rate, Mean: .latencies.mean, P50: .latencies."50th", P90: .latencies."90th", P95: .latencies."95th", P99: .latencies."99th", Max: .latencies.max, Min: .latencies.min, SuccessRate: .success, Throughput: .throughput, "status_codes": .status_codes, "errors": .errors})' ${path}/results/report*_w${wf}_*json > ${path}/results/w${wf}_results.json
   curl -X POST -H "Content-Type: application/json" -d @${path}/results/w${wf}_results.json $3
   sleep 2
done
