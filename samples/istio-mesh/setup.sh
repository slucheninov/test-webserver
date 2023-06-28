#!/usr/bin/env bash

cluster1="prod-4"
cluster2="prod-5"
namespace="sample"

export CTX_CLUSTER1=gke_production-4f83b34d_us-central1_$cluster1
export CTX_CLUSTER2=gke_production-4f83b34d_us-central1_$cluster2

app="https://raw.githubusercontent.com/slucheninov/test-webserver/main/samples/istio-mesh/helloworld.yaml"


# deploy
if [[ $1 = "install" ]]; then
echo "Install demonstration in namespace $namespace"

kubectl --context="${CTX_CLUSTER1}" get secrets/istio-remote-secret-$cluster2 -n istio-system
kubectl --context="${CTX_CLUSTER2}" get secrets/istio-remote-secret-$cluster1 -n istio-system

kubectl create --context="${CTX_CLUSTER1}" namespace $namespace
kubectl label --context="${CTX_CLUSTER1}" namespace $namespace istio-injection=enabled
kubectl create --context="${CTX_CLUSTER2}" namespace $namespace
kubectl label --context="${CTX_CLUSTER2}" namespace $namespace istio-injection=enabled

kubectl apply --context="${CTX_CLUSTER1}" -f $app -l service=helloworld -n $namespace
kubectl apply --context="${CTX_CLUSTER2}" -f $app -l service=helloworld -n $namespace

kubectl apply --context="${CTX_CLUSTER1}" -f $app -l version=v1 -n $namespace
kubectl get pod --context="${CTX_CLUSTER1}" -n $namespace -l app=helloworld

kubectl apply --context="${CTX_CLUSTER2}" -f $app -l version=v2 -n $namespace
kubectl get pod --context="${CTX_CLUSTER2}" -n $namespace -l app=helloworld

# Deploy Sleep
kubectl apply --context="${CTX_CLUSTER1}" -f https://raw.githubusercontent.com/istio/istio/release-1.14/samples/sleep/sleep.yaml -n $namespace
kubectl apply --context="${CTX_CLUSTER2}" -f https://raw.githubusercontent.com/istio/istio/release-1.14/samples/sleep/sleep.yaml -n $namespace

kubectl get pod --context="${CTX_CLUSTER1}" -n $namespace -l app=sleep
kubectl get pod --context="${CTX_CLUSTER2}" -n $namespace -l app=sleep

kubectl scale --context="${CTX_CLUSTER1}" -n $namespace deploy -l app=helloworld --replicas=2
kubectl scale --context="${CTX_CLUSTER2}" -n $namespace deploy -l app=helloworld --replicas=2
fi


if [[ $1 = "destinationrule" ]]; then
kubectl --context="${CTX_CLUSTER1}" apply -n $namespace -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: helloworld
  namespace: $namespace
spec:
  host: helloworld.$namespace.svc.cluster.local
  trafficPolicy:
    loadBalancer:
      simple: LEAST_REQUEST
      localityLbSetting:
        enabled: true
    outlierDetection:
      consecutiveErrors: 1
      consecutiveGatewayErrors: 5
      interval: 5s
      baseEjectionTime: 30s
      maxEjectionPercent: 20
      consecutive5xxErrors: 5
EOF

kubectl --context="${CTX_CLUSTER2}" apply -n $namespace -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: helloworld
  namespace: $namespace
spec:
  host: helloworld.$namespace.svc.cluster.local
  trafficPolicy:
    loadBalancer:
      simple: LEAST_REQUEST
      localityLbSetting:
        enabled: true
    outlierDetection:
      consecutiveErrors: 1
      consecutiveGatewayErrors: 5
      interval: 5s
      baseEjectionTime: 30s
      maxEjectionPercent: 20
      consecutive5xxErrors: 5
EOF


#          consecutiveGatewayErrors: 5
#          interval: 5s
#          baseEjectionTime: 30s
#          maxEjectionPercent: 20


fi

if [[ $1 = "run" ]]; then
echo "Run demonstration namespace $namespace on cluster ${CTX_CLUSTER1}"
while true; do
kubectl exec --context="${CTX_CLUSTER1}" -n $namespace -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n $namespace -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.$namespace:5000/hello
done
fi

if [[ $1 = "delete" ]]; then
echo "Remove all in namespace $namespace on cluster ${CTX_CLUSTER1}"
kubectl --context="${CTX_CLUSTER1}" delete ns $namespace --ignore-not-found=true
echo "Remove all in namespace $namespace on cluster ${CTX_CLUSTER2}"
kubectl --context="${CTX_CLUSTER2}" delete ns $namespace --ignore-not-found=true
fi
