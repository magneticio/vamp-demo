#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

source ./scripts/common.sh

vamp_connect $CLOUD
vamp_login $NAME $CLOUD

vamp_create gateway ./demos/03-policy/vshop-gateway.yaml
vamp_disconnect $CLOUD

kubectl apply -f  ./demos/03-policy/vshop-v1.yaml --namespace vampio-organization-environment
kubectl rollout status deployment/vshop-policy-v1 --namespace vampio-organization-environment

forklift_connect

forklift add releasepolicy hotfix --config ./vamp/forklift-config.yaml --organization organization --environment environment  --file ./demos/03-policy/hotfix-policy.json

forklift_disconnect

#vamp_create breed ./vamp/artifacts/breeds/release.yaml
#vamp_create workflow ./vamp/artifacts/workflows/release.yaml

#kubectl apply -f  ./demos/03-policy/vshop-v2.yaml --namespace vampio-organization-environment && kubectl rollout status deployment/vshop-policy-v2 --namespace vampio-organization-environment