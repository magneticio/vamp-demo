#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

DEMOPATH=./demos/04-particles

source ./scripts/common.sh

if [ $CLOUD != "local" ]; then
    open http://particles.$NAME.demo.vamp.cloud
else
    open http://localhost:41004
    gateway_connect particles 41004
fi
