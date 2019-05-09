#!/bin/sh

export NAME=${1:-vamp}

source ./scripts/common.sh

vamp_login $NAME

vamp_deploy ./demos/02-experiment/vshop-deployment.yaml vshop-experiment

kubectl apply -f  ./demos/02-experiment/kibana.yml --namespace default
kubectl rollout status deployment/kibana --namespace default

vamp_create breed ./demos/02-experiment/voting-breed.yaml
vamp_create workflow ./demos/02-experiment/voting-workflow.yaml
vamp_create gateway ./demos/02-experiment/kibana-gateway.yaml
