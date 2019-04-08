#!/bin/bash

NAME=$1

terraform destroy -input=false -var "name=${NAME}"
