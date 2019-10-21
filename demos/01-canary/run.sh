#!/bin/sh

export NAME=${1:-vamp}
export CLOUD=${2:-local}

PORT=41001
SERVICE=vshop-canary

source ./scripts/common.sh

if [ $CLOUD != "local" ]; then
    open http://$SERVICE.$NAME.demo.vamp.cloud
else
    echo "Start port forwarding"
    vamp_connect $CLOUD
    kubectl port-forward svc/$SERVICE $PORT:$PORT --namespace vampio-organization-environment &
    open http://localhost:41001
    open http://localhost:8080
    read -n 1 -s -r -p "Press any key to continue"
    vamp_disconnect $CLOUD
fi
