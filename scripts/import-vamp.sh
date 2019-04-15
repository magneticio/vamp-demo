#!/bin/bash

KUBERNETES_NAMESPACE="default"

echo "Start port forwarding"
kubectl port-forward svc/vamp 8080:8080 --namespace ${KUBERNETES_NAMESPACE} &

sleep 5

echo "Login to Vamp"
vamp login -u admin --host http://localhost:8080

export VAMP_NAMESPACE=$(vamp list namespaces | awk '{print $2}' | tail -n1)
export VAMP_ORGANIZATION=${1:-vamp}
export VAMP_ENVIRONMENT=${2:-demo}

echo "Stop port forwarding"
pkill -f kubectl
