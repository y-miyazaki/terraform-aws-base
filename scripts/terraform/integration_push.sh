#!/bin/bash
set -e
DIR=${1:-./}

if [ -n "${AWS_ACCESS_KEY_ID}" ] && [ -n "${AWS_SECRET_ACCESS_KEY}" ] && [ -n "${AWS_DEFAULT_REGION}" ]; then
    aws configure set aws_access_key_id "${AWS_ACCESS_KEY_ID}" --profile default
    aws configure set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}" --profile default
    aws configure set region "${AWS_DEFAULT_REGION}" --profile default
else
fi

# Create terraform plugin dirctory.
if [ -n "${TF_PLUGIN_CACHE_DIR}" ]; then
    mkdir -p "${TF_PLUGIN_CACHE_DIR}"
else
fi

cd $DIR
echo "#--------------------------------------------------------------"
echo "# tfenv install ($PWD)"
echo "#--------------------------------------------------------------"
tfenv install
echo "#--------------------------------------------------------------"
echo "# terraform init ($PWD)"
echo "#--------------------------------------------------------------"
terraform init -reconfigure -backend-config=terraform."${ENV}".tfbackend
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
