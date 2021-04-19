#!/bin/bash
set -e
DIR=${1:-./}

cd $DIR
echo "#--------------------------------------------------------------"
echo "# terraform plan ($PWD)"
echo "#--------------------------------------------------------------"
#terraform init -reconfigure -backend-config=terraform."${ENV}".tfbackend
terraform init
terraform apply --auto-approve -var-file=terraform."${ENV}".tfvars
