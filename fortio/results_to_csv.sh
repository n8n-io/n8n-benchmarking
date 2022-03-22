#!/bin/bash

# path=/home/ubuntu/fortio
path=.

for wf in {4..4}
do
   echo "Generating csv for w${wf}"
   jq -s --arg WF "$wf" --arg MODE "$1" --arg INSTANCE "$2" 'map({Workflow: $WF, Mode: $MODE, Instance: $INSTANCE, RequestedQPS: .RequestedQPS, ActualQPS: .ActualQPS, NumThreads: .NumThreads, P50: .DurationHistogram.Percentiles[0].Value, P75: .DurationHistogram.Percentiles[1].Value, P90: .DurationHistogram.Percentiles[2].Value, P99: .DurationHistogram.Percentiles[3].Value, "P99.9": .DurationHistogram.Percentiles[4].Value, timeout: .HTTPReqTimeOut, retCodes: .RetCodes, totalCount: .Sizes.Count})' ${path}/results/*_w${wf}_*json > ${path}/results/w${wf}_results.json
   curl -X POST -H "Content-Type: application/json" -d @${path}/results/w${wf}_results.json https://ahsan.app.n8n.cloud/webhook/submit-result
done
