#!/bin/bash
CLOUD=${1:-gcloud}
ORGANIZATION=${2:-vamp}
ENVIRONMENT=${3:-demo}
VAMP_VERSION=${4:-1.1.1}

TEMP_DIR="./.temp"
TEMPLATE_DIR="./kubernetes/$CLOUD"
KUBERNETES_NAMESPACE="default"

deploy() {
    DEPLOYMENT=$1
    DEPLOYMENT_NAMESPACE=${2:-$KUBERNETES_NAMESPACE}
    set -e
    echo "Deploying:" ${DEPLOYMENT}
    sed -e "s|KUBERNETES_NAMESPACE|${DEPLOYMENT_NAMESPACE}|g" ${TEMPLATE_DIR}/${DEPLOYMENT}.yml > ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_IP_NAME|${VAMP_IP}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_IP_ADDRESS|${VAMP_IP}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VGA_IP_NAME|${VAMP_IP}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VGA_IP_ADDRESS|${VAMP_IP}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_VERSION|${VAMP_VERSION}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    kubectl apply --namespace=${DEPLOYMENT_NAMESPACE} -f ${TEMP_DIR}/${DEPLOYMENT}.yml
    set +e
}

mkdir -p $TEMP_DIR

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
VAMP_POD=$(kubectl get --no-headers=true pods -o name --namespace ${KUBERNETES_NAMESPACE} | awk -F "/" '{print $2}' | grep vamp)
kubectl delete pod $VAMP_POD

deploy vamp-gateway-agent vampio-${ORGANIZATION}-${ENVIRONMENT}
kubectl rollout status deployment/vamp-gateway-agent --namespace=vampio-${ORGANIZATION}-${ENVIRONMENT}

rm -rf $TEMP_DIR
