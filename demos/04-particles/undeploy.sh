#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

DEMOPATH=./demos/04-particles

source ./scripts/common.sh

vamp_connect $CLOUD
vamp_login $NAME $CLOUD

vamp delete gateway particles
vamp_disconnect $CLOUD

kubectl delete -f $DEMOPATH/particles-v1.0.0.yaml --namespace vampio-organization-environment
kubectl delete -f $DEMOPATH/particles-v1.0.1.yaml --namespace vampio-organization-environment
kubectl delete -f $DEMOPATH/particles-v1.1.0.yaml --namespace vampio-organization-environment
kubectl delete -f $DEMOPATH/particles-v1.1.1.yaml --namespace vampio-organization-environment

forklift_connect

forklift delete releasepolicy patch --config ./vamp/forklift-config.yaml --organization organization --environment environment
forklift delete releasepolicy minor --config ./vamp/forklift-config.yaml --organization organization --environment environment

forklift_disconnect
