#!/bin/bash
set -e

NAME=$1
CLOUD=${2:-gcloud}
REGION=${3:-europe-west4}

gcloud auth application-default login

terraform init
terraform apply -var "name=${NAME}" -var "cloud=${CLOUD}" -var "region=${REGION}"

gcloud container clusters get-credentials ${NAME} --region ${REGION}
