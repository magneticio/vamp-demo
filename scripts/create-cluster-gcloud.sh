#!/bin/bash

NAME=$1
CLOUD=${2:-gcloud}
REGION=${3:-europe-west4}

gcloud auth application-default login

terraform apply -input=false -var "name=${NAME}" -var "cloud=${CLOUD}" -var "region=${REGION}"

gcloud container clusters get-credentials ${NAME} --region ${REGION}

export VAMP_IP=$(terraform output vamp_ip_name)
export VGA_IP=$(terraform output vga_ip_name)