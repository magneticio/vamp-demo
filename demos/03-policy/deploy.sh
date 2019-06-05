#!/bin/sh

export NAME=${1:-vamp}

source ./scripts/common.sh

vamp_login $NAME

vamp_create gateway ./demos/03-policy/vshop-gateway.yaml

kubectl apply -f  ./demos/03-policy/vshop-v1.yaml --namespace vampio-organization-environment
kubectl rollout status deployment/vshop-policy-v1 --namespace vampio-organization-environment

vamp_create breed ./vamp/artifacts/breeds/release.yaml
vamp_create workflow ./vamp/artifacts/workflows/release.yaml

#kubectl apply -f  ./demos/03-policy/vshop-v2.yaml --namespace vampio-organization-environment
#kubectl rollout status deployment/vshop-policy-v2 --namespace vampio-organization-environment