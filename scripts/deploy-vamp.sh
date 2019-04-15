#!/bin/bash
CLOUD=${1:-gcloud}
ORGANIZATION=${2:-vamp}
ENVIRONMENT=${3:-demo}
VAMP_VERSION=${4:-1.1.1}

KUBERNETES_NAMESPACE="default"

source ./scripts/common.sh

deploy mysql
deploy vault
deploy elasticsearch
deploy natsstreaming
kubectl rollout status deployment/mysql --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/vault --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/elasticsearch --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/nats-streaming --namespace=${KUBERNETES_NAMESPACE}

REGSECRET=$(kubectl get --no-headers=true secret -o name --namespace=${KUBERNETES_NAMESPACE} | awk -F "/" '{print $2}' | grep regsecret)
if [ -z $REGSECRET ]; then
    echo "Secret 'regsecret' not found. Please login to Docker Hub..."
    read -p 'Docker Hub - Username: ' dockeruser
    read -sp 'Docker Hub - Password: ' dockerpass
    kubectl create secret docker-registry regsecret --docker-server=https://index.docker.io/v1/ --docker-username=${dockeruser} --docker-password=${dockerpass} --docker-email=docker@vamp.io
fi

deploy vamp
kubectl rollout status deployment/vamp --namespace=${KUBERNETES_NAMESPACE}

# Configure Vamp
echo "Start port forwarding"
kubectl port-forward svc/mysql 3306:3306 --namespace ${KUBERNETES_NAMESPACE} &
kubectl port-forward svc/vault 8200:8200 --namespace ${KUBERNETES_NAMESPACE} &

sleep 5

forklift create organization ${ORGANIZATION} --file ./vamp/organization-config.yaml --config ./vamp/forklift-config.yaml
forklift create user admin --role admin --organization ${ORGANIZATION} --config ./vamp/forklift-config.yaml
forklift create environment ${ENVIRONMENT} --organization ${ORGANIZATION} --config ./vamp/forklift-config.yaml --file ./vamp/environment-config.yaml --artifacts ./vamp/artifacts

echo "Stop port forwarding"
pkill -f kubectl

# Create Kubernetes Namespace
VAMP_NAMESPACE=$(kubectl get --no-headers=true namespace -o name | awk -F "/" '{print $2}' | grep vampio-${ORGANIZATION}-${ENVIRONMENT})
if [ -z $VAMP_NAMESPACE ]; then
    echo "Create Namespace vampio-${ORGANIZATION}-${ENVIRONMENT}"
    kubectl create ns vampio-${ORGANIZATION}-${ENVIRONMENT}
fi

# Force a restart of Vamp
restart_vamp ${KUBERNETES_NAMESPACE}

source ./scripts/import-vamp.sh ${ORGANIZATION} ${ENVIRONMENT}

deploy vamp-gateway-agent vampio-${ORGANIZATION}-${ENVIRONMENT}
kubectl rollout status deployment/vamp-gateway-agent --namespace=vampio-${ORGANIZATION}-${ENVIRONMENT}

rm -rf $TEMP_DIR
