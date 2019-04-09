#!/bin/sh

CLOUD=${1:-gcloud}
ORGANIZATION=${2:-vamp}
ENVIRONMENT=${3:-demo}
VAMP_VERSION=${4:-1.1.1}

KUBERNETES_NAMESPACE="default"

source ./scripts/common.sh

echo "Update resources"
deploy mysql
deploy vault
deploy elasticsearch
deploy natsstreaming
kubectl rollout status deployment/mysql --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/vault --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/elasticsearch --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/nats-streaming --namespace=${KUBERNETES_NAMESPACE}

deploy vamp
kubectl rollout status deployment/vamp --namespace=${KUBERNETES_NAMESPACE}

echo "Start port forwarding"
kubectl port-forward svc/mysql 3306:3306 --namespace default &
kubectl port-forward svc/vault 8200:8200 --namespace default &

sleep 5

forklift update organization ${ORGANIZATION} --file ./vamp/organization-config.yaml --config ./vamp/forklift-config.yaml
forklift update environment ${ENVIRONMENT} --organization ${ORGANIZATION} --file ./vamp/environment-config.yaml --config ./vamp/forklift-config.yaml

echo "Stop port forwarding"
pkill -f kubectl

# Force a restart of Vamp
restart_vamp ${KUBERNETES_NAMESPACE}
