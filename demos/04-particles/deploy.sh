#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

DEMOPATH=./demos/04-particles

source ./scripts/common.sh

vamp_connect $CLOUD
vamp_login $NAME $CLOUD

vamp_create gateway $DEMOPATH/particles-gateway.yaml
vamp_disconnect $CLOUD

kubectl apply -f  $DEMOPATH/particles-v1.0.0.yaml --namespace vampio-organization-environment
kubectl rollout status deployment/particles-v1.0.0 --namespace vampio-organization-environment

forklift_connect

forklift add releasepolicy patch --config ./vamp/forklift-config.yaml --organization organization --environment environment  --file $DEMOPATH/policy-patch.json
forklift add releasepolicy minor --config ./vamp/forklift-config.yaml --organization organization --environment environment  --file $DEMOPATH/policy-minor.json

forklift_disconnect

#vamp_create breed ./vamp/artifacts/breeds/release.yaml
#vamp_create workflow ./vamp/artifacts/workflows/release.yaml

#kubectl apply -f  ./demos/03-policy/vshop-v2.yaml --namespace vampio-organization-environment && kubectl rollout status deployment/vshop-policy-v2 --namespace vampio-organization-environment