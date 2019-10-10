#!/bin/sh

NAME=$1
REGION=${2:-europe-west4}

export VAMP_IP_ADDRESS=$(gcloud compute addresses describe ${NAME}-vamp --region ${REGION} | grep address: | awk '{print $2}')
export VGA_IP_ADDRESS=$(gcloud compute addresses describe ${NAME}-vga --region ${REGION} | grep address: | awk '{print $2}')