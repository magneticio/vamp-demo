#!/bin/sh

export NAME=${1:-vamp}

source ./scripts/common.sh

vamp_login $NAME

vamp_deploy ./demos/01-canary/vshop-deployment.yaml vshop-canary
vamp_create breed ./demos/01-canary/canary-breed.yaml
vamp_create workflow ./demos/01-canary/canary-workflow.yaml