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

waitfor_ip() {
    external_ip=""; while [ -z $external_ip ]; do echo "Waiting for endpoint..."; external_ip=$(kubectl get svc $1 --namespace $2 --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done;
}

# Vamp
vamp_connect() {
    cloud=${1:-local}
    if [ $cloud == "local" ]; then
        echo "Start port forwarding"
        kubectl port-forward svc/vamp 8080:8080 --namespace ${KUBERNETES_NAMESPACE} &
        sleep 5
    fi
} 

vamp_disconnect() {
    cloud=${1:-local}
    if [ $cloud == "local" ]; then
        echo "Stop port forwarding"
        pkill -f kubectl
    fi
}

forklift_connect() {
    echo "Start port forwarding"
    kubectl port-forward svc/mysql 3306:3306 --namespace ${KUBERNETES_NAMESPACE} &
    kubectl port-forward svc/vault 8200:8200 --namespace ${KUBERNETES_NAMESPACE} &

    sleep 5
}

forklift_disconnect() {
    echo "Stop port forwarding"
    pkill -f kubectl
}

vamp_login() {
    name=${1:-vamp}
    cloud=${2:-local}
    if [ $cloud != "local" ]; then
        export VAMP_HOST="http://$name.demo.vamp.cloud:8080"
    else
        export VAMP_HOST="http://localhost:8080"
    fi
    export VAMP_NAMESPACE="6d1339c7c7a1ac54246a57320bb1dd15176ce29"

    echo "Login to Vamp ($VAMP_HOST)"
    vamp login -u admin
}

vamp_deploy() {
    file=${1}
    name=${2}

    sed -e "s|__NAME__|${NAME}|g" $file > ${TEMP_DIR}/${name}.yml

    vamp deploy -f ${TEMP_DIR}/${name}.yml $name
}

vamp_create() {
    artifact=${1}
    file=${2}

    sed -e "s|__NAME__|${NAME}|g" $file > ${TEMP_DIR}/artifact.yml

    vamp create $artifact -f ${TEMP_DIR}/artifact.yml
}

gateway_connect() {
    service=${1}
    port=${2}

    echo "Start port forwarding"
    kubectl port-forward svc/$service $port:$port --namespace ${KUBERNETES_NAMESPACE}
}