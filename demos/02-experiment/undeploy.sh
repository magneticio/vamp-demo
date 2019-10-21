#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

source ./scripts/common.sh

vamp_connect $CLOUD
vamp_login $NAME $CLOUD

vamp delete workflow voting
vamp undeploy vshop-experiment
vamp delete blueprint vshop-experiment
vamp delete gateway kibana
vamp_disconnect $CLOUD

kubectl delete -f  ./demos/02-experiment/kibana.yml --namespace default
