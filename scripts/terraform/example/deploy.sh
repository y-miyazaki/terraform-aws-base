#!/bin/bash
set -e
DIR=${1:-./}

if [ -n "${AWS_ACCESS_KEY_ID}" ] && [ -n "${AWS_SECRET_ACCESS_KEY}" ] && [ -n "${AWS_DEFAULT_REGION}" ]; then
    aws configure set aws_access_key_id "${AWS_ACCESS_KEY_ID}" --profile default
    aws configure set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}" --profile default
    aws configure set region "${AWS_DEFAULT_REGION}" --profile default
else
    echo "can't set AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY/AWS_DEFAULT_REGION."
    exit 1
fi

# Create terraform plugin dirctory.
if [ -n "${TF_PLUGIN_CACHE_DIR}" ]; then
    mkdir -p "${TF_PLUGIN_CACHE_DIR}"
else
    echo "can't set TF_PLUGIN_CACHE_DIR."
    exit 1
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
echo "# terraform apply ($PWD)"
echo "#--------------------------------------------------------------"
terraform apply --auto-approve -var-file=terraform."${ENV}".tfvars
