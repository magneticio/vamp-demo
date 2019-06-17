#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

source ./scripts/common.sh

vamp_connect $CLOUD
vamp_login $NAME $CLOUD

vamp_deploy ./demos/01-canary/vshop-deployment.yaml vshop-canary
vamp_create breed ./demos/01-canary/canary-breed.yaml
vamp_create workflow ./demos/01-canary/canary-workflow.yaml

vamp_disconnect $CLOUD