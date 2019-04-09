#!/bin/bash

CLOUD=${1:-gcloud}
KUBERNETES_NAMESPACE=${2:-default}

VAMP_NAMESPACE=$(kubectl get --no-headers=true namespace -o name | awk -F "/" '{print $2}' | grep vampio-)

echo "Deleting namespace $VAMP_NAMESPACE"
kubectl delete namespace $VAMP_NAMESPACE

echo "Deleting Vamp in namespace $KUBERNETES_NAMESPACE"
kubectl delete --namespace=${KUBERNETES_NAMESPACE} -f ./kubernetes/$CLOUD/vamp.yml
kubectl delete --namespace=${KUBERNETES_NAMESPACE} -f ./kubernetes/$CLOUD/elasticsearch.yml
kubectl delete --namespace=${KUBERNETES_NAMESPACE} -f ./kubernetes/$CLOUD/natsstreaming.yml
kubectl delete --namespace=${KUBERNETES_NAMESPACE} -f ./kubernetes/$CLOUD/mysql.yml
kubectl delete --namespace=${KUBERNETES_NAMESPACE} -f ./kubernetes/$CLOUD/vault.yml
