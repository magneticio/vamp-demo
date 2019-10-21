#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

source ./scripts/common.sh

vamp_connect $CLOUD
vamp_login $NAME $CLOUD

vamp delete workflow canary
vamp undeploy vshop-canary
vamp delete blueprint vshop-canary
vamp_disconnect $CLOUD
