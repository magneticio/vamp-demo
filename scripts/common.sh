#!/bin/bash
TEMP_DIR="./.temp"
TEMPLATE_DIR="./kubernetes/$CLOUD"
KUBERNETES_NAMESPACE="default"

mkdir -p $TEMP_DIR

deploy() {
    DEPLOYMENT=$1
    DEPLOYMENT_NAMESPACE=${2:-$KUBERNETES_NAMESPACE}
    set -e
    echo "Deploying:" ${DEPLOYMENT}
    sed -e "s|KUBERNETES_NAMESPACE|${DEPLOYMENT_NAMESPACE}|g" ${TEMPLATE_DIR}/${DEPLOYMENT}.yml > ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_IP_NAME|${VAMP_IP_NAME}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_IP_ADDRESS|${VAMP_IP_ADDRESS}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VGA_IP_NAME|${VGA_IP_NAME}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VGA_IP_ADDRESS|${VGA_IP_ADDRESS}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_VERSION|${VAMP_VERSION}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_NAMESPACE|${VAMP_NAMESPACE}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_ORGANIZATION|${VAMP_ORGANIZATION}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|VAMP_ENVIRONMENT|${VAMP_ENVIRONMENT}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    kubectl apply --namespace=${DEPLOYMENT_NAMESPACE} -f ${TEMP_DIR}/${DEPLOYMENT}.yml
    set +e
}

restart_vamp() {
    DEPLOYMENT_NAMESPACE=${1:-$KUBERNETES_NAMESPACE}
    # Force a restart of Vamp
    VAMP_POD=$(kubectl get --no-headers=true pods -o name --namespace ${DEPLOYMENT_NAMESPACE} | awk -F "/" '{print $2}' | grep vamp)
    kubectl delete pod $VAMP_POD --namespace ${DEPLOYMENT_NAMESPACE}
}