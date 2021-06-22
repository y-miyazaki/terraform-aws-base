#!/bin/bash
set -e
DIR=${1:-./}

cd $DIR
echo "#--------------------------------------------------------------"
echo "# tfenv install ($PWD)"
echo "#--------------------------------------------------------------"
tfenv install
echo "#--------------------------------------------------------------"
echo "# terraform init ($PWD)"
echo "#--------------------------------------------------------------"
#terraform init -reconfigure -backend-config=terraform."${ENV}".tfbackend
terraform init
echo "#--------------------------------------------------------------"
echo "# terraform plan ($PWD)"
echo "#--------------------------------------------------------------"
terraform apply --auto-approve -var-file=terraform."${ENV}".tfvars
