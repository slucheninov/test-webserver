#!/usr/bin/env bash

cluster1="prod-4"
namespace="sample"

export CTX_CLUSTER1=gke_production-4f83b34d_us-central1_$cluster1

for podIP in `kubectl get pod -n sample -l app=helloworld -o=jsonpath='{.items[*].status.podIP}'`; do

curl -sS http://$podIP:5000/api -X POST --data '{"status": 500}'

done
