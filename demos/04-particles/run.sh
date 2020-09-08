#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

PORT=41004
SERVICE=particles

source ./scripts/common.sh

if [ $CLOUD != "local" ]; then
    open http://$SERVICE.$NAME.demo-ee.vamp.cloud
else
    echo "Start port forwarding"
    vamp_connect $CLOUD
    kubectl port-forward svc/$SERVICE $PORT:$PORT --namespace vampio-organization-environment &
    open http://localhost:41004
    open http://localhost:8080
    read -n 1 -s -r -p "Press any key to continue"
    vamp_disconnect $CLOUD
fi
