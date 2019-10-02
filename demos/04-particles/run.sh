#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

DEMOPATH=./demos/04-particles
PORT=41004
SERVICE=particles

source ./scripts/common.sh

if [ $CLOUD != "local" ]; then
    open http://particles.$NAME.demo.vamp.cloud
else
    vamp_connect $CLOUD
    open http://localhost:8080
    open http://localhost:41004
    echo "Start port forwarding"
    kubectl port-forward svc/$SERVICE $PORT:$PORT --namespace vampio-organization-environment &
    read -n 1 -s -r -p "Press any key to continue"
    vamp_disconnect $CLOUD
fi
