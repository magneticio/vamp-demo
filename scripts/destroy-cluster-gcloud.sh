#!/bin/bash

NAME=$1
REGION=${2:-europe-west4}
ZONE=${3:-${REGION}-b}

# Remove Cluster
gcloud container clusters delete ${NAME}-demo-ee --zone ${ZONE} -q

# Remove DNS Records
VAMP_IP_ADDRESS=$(gcloud compute addresses describe ${NAME}-vamp --region ${REGION} | grep address: | awk '{print $2}')
VGA_IP_ADDRESS=$(gcloud compute addresses describe ${NAME}-vga --region ${REGION} | grep address: | awk '{print $2}')
gcloud dns record-sets transaction start --zone="demo-vamp-cloud"
gcloud dns record-sets transaction remove $VAMP_IP_ADDRESS --name="${NAME}.demo.vamp.cloud" --ttl="300" --type="A" --zone="demo-vamp-cloud"
gcloud dns record-sets transaction remove $VGA_IP_ADDRESS --name="*.${NAME}.demo.vamp.cloud" --ttl="300" --type="A" --zone="demo-vamp-cloud"
gcloud dns record-sets transaction execute --zone="demo-vamp-cloud"

# Remove IP Addresses
gcloud compute addresses delete ${NAME}-vamp --region ${REGION} -q
gcloud compute addresses delete ${NAME}-vga --region ${REGION} -q
