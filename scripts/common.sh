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
    sed -e "s|__KUBERNETES_NAMESPACE__|${DEPLOYMENT_NAMESPACE}|g" ${TEMPLATE_DIR}/${DEPLOYMENT}.yml > ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|__VAMP_IP_NAME__|${VAMP_IP_NAME}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|__VAMP_IP_ADDRESS__|${VAMP_IP_ADDRESS}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|__VGA_IP_NAME__|${VGA_IP_NAME}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|__VGA_IP_ADDRESS__|${VGA_IP_ADDRESS}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|__VAMP_VERSION__|${VAMP_VERSION}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|__VAMP_NAMESPACE__|${VAMP_NAMESPACE}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|__VAMP_ORGANIZATION__|${VAMP_ORGANIZATION}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    sed -i.bak "s|__VAMP_ENVIRONMENT__|${VAMP_ENVIRONMENT}|g" ${TEMP_DIR}/${DEPLOYMENT}.yml
    kubectl apply --namespace=${DEPLOYMENT_NAMESPACE} -f ${TEMP_DIR}/${DEPLOYMENT}.yml
    set +e
}

restart_vamp() {
    DEPLOYMENT_NAMESPACE=${1:-$KUBERNETES_NAMESPACE}
    # Force a restart of Vamp
    VAMP_POD=$(kubectl get --no-headers=true pods -o name --namespace ${DEPLOYMENT_NAMESPACE} | awk -F "/" '{print $2}' | grep vamp)
    kubectl delete pod $VAMP_POD --namespace ${DEPLOYMENT_NAMESPACE}
}