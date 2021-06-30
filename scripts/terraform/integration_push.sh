#!/bin/bash
set -e
DIR=${1:-./}

cd $DIR
echo "#--------------------------------------------------------------"
echo "# tfenv ($PWD)"
echo "#--------------------------------------------------------------"
tfenv install
echo "#--------------------------------------------------------------"
echo "# terraform init ($PWD)"
echo "#--------------------------------------------------------------"
# terraform init -reconfigure -backend-config=terraform."${ENV}".tfbackend
terraform init
echo "#--------------------------------------------------------------"
echo "# tflint ($PWD)"
echo "#--------------------------------------------------------------"
tflint --module
echo "#--------------------------------------------------------------"
echo "# tfsec ($PWD)"
echo "#--------------------------------------------------------------"
tfsec --tfvars-file terraform."${ENV}".tfvars
# echo "#--------------------------------------------------------------"
# echo "# terraform plan ($PWD)"
# echo "#--------------------------------------------------------------"
# terraform plan -lock=false -no-color -var-file=terraform."${ENV}".tfvars
