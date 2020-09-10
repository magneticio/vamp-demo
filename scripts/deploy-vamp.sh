#!/bin/bash
CLOUD=${1:-gcloud}
VAMP_VERSION=${2:-1.2.0}
ORGANIZATION=${3:-organization}
ENVIRONMENT=${4:-environment}


KUBERNETES_NAMESPACE="default"

source ./scripts/common.sh
# source ~/.vampdemo/dh-login

deploy mysql
deploy vault
deploy elasticsearch
deploy natsstreaming
kubectl rollout status deployment/mysql --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/vault --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/elasticsearch --namespace=${KUBERNETES_NAMESPACE}
kubectl rollout status deployment/nats-streaming --namespace=${KUBERNETES_NAMESPACE}

# Deploy Helm
if ! type "helm" > /dev/null 2>&1; then
    kubectl apply -f ./kubernetes/helm.yaml
    helm init --service-account helm
fi

REGSECRET=$(kubectl get --no-headers=true secret -o name --namespace=${KUBERNETES_NAMESPACE} | awk -F "/" '{print $2}' | grep regsecret)
if [ -z $REGSECRET ]; then
    echo "Secret 'regsecret' not found. Please login to Docker Hub..."
    read -p 'Docker Hub - Username: ' dockeruser
    read -sp 'Docker Hub - Password: ' dockerpass
    kubectl create secret docker-registry regsecret --docker-server=https://index.docker.io/v1/ --docker-username=${dockeruser} --docker-password=${dockerpass} --docker-email=docker@vamp.io
    kubectl get ns vampio-${ORGANIZATION}-${ENVIRONMENT} || kubectl create ns vampio-${ORGANIZATION}-${ENVIRONMENT}
    kubectl --namespace=vampio-${ORGANIZATION}-${ENVIRONMENT} create secret docker-registry regsecret --docker-server=https://index.docker.io/v1/ --docker-username=${dockeruser} --docker-password=${dockerpass} --docker-email=docker@vamp.io
fi

deploy vamp
kubectl rollout status deployment/vamp --namespace=${KUBERNETES_NAMESPACE}

# Configure Vamp
forklift_connect

forklift create organization ${ORGANIZATION} --file ./vamp/organization-config.yaml --config ./vamp/forklift-config.yaml
# forklift create user admin --role admin --organization ${ORGANIZATION} --config ./vamp/forklift-config.yaml
forklift add user --organization ${ORGANIZATION} --file ./vamp/user-configuration.json --config ./vamp/forklift-config.yaml
forklift create environment ${ENVIRONMENT} --organization ${ORGANIZATION} --config ./vamp/forklift-config.yaml --file ./vamp/environment-config.yaml --artifacts ./vamp/artifacts

forklift_disconnect

# Create Kubernetes Namespace
VAMP_NAMESPACE=$(kubectl get --no-headers=true namespace -o name | awk -F "/" '{print $2}' | grep vampio-${ORGANIZATION}-${ENVIRONMENT})
if [ -z $VAMP_NAMESPACE ]; then
    echo "Create Namespace vampio-${ORGANIZATION}-${ENVIRONMENT}"
    kubectl create ns vampio-${ORGANIZATION}-${ENVIRONMENT}
    kubectl --namespace=vampio-${ORGANIZATION}-${ENVIRONMENT} get secret docker-registry regsecret || kubectl --namespace=vampio-${ORGANIZATION}-${ENVIRONMENT} create secret docker-registry regsecret --docker-server=https://index.docker.io/v1/ --docker-username=${dockeruser} --docker-password=${dockerpass} --docker-email=docker@vamp.io
fi

# Force a restart of Vamp
restart_vamp ${KUBERNETES_NAMESPACE}

deploy vamp-gateway-agent vampio-${ORGANIZATION}-${ENVIRONMENT}
# kubectl rollout status deployment/vamp-gateway-agent --namespace=vampio-${ORGANIZATION}-${ENVIRONMENT}

# Wait until Vamp is available
if [ $CLOUD != "local" ]; then
    echo "Wait for Vamp"
    waitfor_ip vamp ${KUBERNETES_NAMESPACE}
    echo "Wait for Vamp Gateway Agent"
    waitfor_ip vamp-gateway-agent vampio-${ORGANIZATION}-${ENVIRONMENT}
fi

rm -rf $TEMP_DIR
