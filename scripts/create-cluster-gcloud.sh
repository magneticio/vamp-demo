#!/bin/bash
set -e

NAME=$1
CLOUD=${2:-gcloud}
REGION=${3:-europe-west4}
ZONE=${4:-${REGION}-b}
NODES=${5:-4}
MAX_NODES=8
MACHINE=${6:-n1-standard-2}

# gcloud auth application-default login

# Create IP Addresses
gcloud compute addresses create ${NAME}-vamp --region ${REGION}
gcloud compute addresses create ${NAME}-vga --region ${REGION}

# Create DNS Records
VAMP_IP_ADDRESS=$(gcloud compute addresses describe ${NAME}-vamp --region ${REGION} | grep address: | awk '{print $2}')
VGA_IP_ADDRESS=$(gcloud compute addresses describe ${NAME}-vga --region ${REGION} | grep address: | awk '{print $2}')
gcloud dns record-sets transaction start --zone="demo-ee-vamp-cloud"
gcloud dns record-sets transaction add $VAMP_IP_ADDRESS --zone="demo-ee-vamp-cloud" --name="${name}.demo-ee.vamp.cloud" --type="A" --ttl="300"
gcloud dns record-sets transaction add $VGA_IP_ADDRESS --zone="demo-ee-vamp-cloud" --name="*.${name}.demo-ee.vamp.cloud" --type="A" --ttl="300"
gcloud dns record-sets transaction execute --zone="demo-ee-vamp-cloud"

# Create Cluster
# gcloud container clusters create ${NAME}-demo-ee --zone ${ZONE} --num-nodes $NODES --machine-type ${MACHINE}
gcloud container clusters create ${NAME}-demo-ee --zone ${ZONE} --machine-type ${MACHINE} --enable-autoscaling --max-nodes=$MAX_NODES --min-nodes=$NODES
gcloud container clusters get-credentials ${NAME}-demo-ee --region ${ZONE}
