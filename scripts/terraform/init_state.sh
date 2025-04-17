#!/bin/bash
#--------------------------------------------------------------
# Create S3 bucket for terraform state.
# You set S3 bucket name to this shell, create S3 bucket and set versioning.
# S3 bucket name adds suffix of aws-id hash for unique name.
#--------------------------------------------------------------
set -e

#------------------------------------------------------------------------
# variables
#------------------------------------------------------------------------
# script directory
SCRIPT_DIR=$(cd "$(dirname "${0}")"; pwd)
# init
IS_BUCKET_AUTO_HASH=0

# usage function
function usage () {
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    if [ -n "${1}" ]; then
        printf "%b%s%b\n" "${RED}" "${1}" "${NC}"
    fi
    cat <<EOF

This command creates a S3 Bucket for Terraform State.
You can also add random hash to bucket name suffix.

Usage:
    $(basename "${0}") -r {region} -b {bucket name} -p {profile}[<options>]
    $(basename "${0}") -r ap-northeast-1 -b terraform-state
    $(basename "${0}") -r ap-northeast-1 -b terraform-state -p default -s

Options:
    -b {bucket name}          S3 bucket name
    -p {aws profile name}     Name of AWS profile
    -r {region}               S3 region
    -s                        If set, a random hash will suffix bucket name.
    -h                        Usage $(basename "${0}")
EOF
    exit 1
}

while getopts b:p:r:sh opt
do
    case $opt in
        b ) BUCKET=$OPTARG ;;
        p ) PROFILE="--profile $OPTARG" ;;
        r ) REGION=$OPTARG ;;
        s ) IS_BUCKET_AUTO_HASH=1 ;;
        h ) usage ;;
        \? ) usage ;;
    esac
done

# check aws command
if [ -z "$(command -v aws)" ]; then
    usage "This command need to install \"aws\"."
fi

# check
if [ -z "${BUCKET}" ]; then
    usage
fi
if [ -z "${REGION}" ]; then
    usage
fi

# option: add hash suffix to bucket name.
if [ $IS_BUCKET_AUTO_HASH -eq 1 ]; then
    RM=$(awk -v min=10000000 -v max=100000000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
    BUCKET="${BUCKET}-${RM}"
fi

# AWS ID取得
# shellcheck disable=SC2086
AWS_ID=$( \
    aws sts get-caller-identity \
    --query 'Account' \
    --output text \
    ${PROFILE} \
) && echo "${AWS_ID}"

if [ -z "${AWS_ID}" ]; then
    usage "can't get AWS_ID"
fi

# create bucket
# shellcheck disable=SC2086
aws s3api create-bucket ${PROFILE} --bucket "${BUCKET}" --create-bucket-configuration LocationConstraint="${REGION}" && :

# public access block
# shellcheck disable=SC2086
aws s3api put-public-access-block ${PROFILE} --bucket "${BUCKET}" --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# versioning
# shellcheck disable=SC2086
aws s3api put-bucket-versioning ${PROFILE} --bucket "${BUCKET}" --versioning-configuration Status=Enabled

# default encrypt
# shellcheck disable=SC2086
aws s3api put-bucket-encryption ${PROFILE} --bucket "${BUCKET}" --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'

# shellcheck disable=SC2086
aws s3api get-bucket-location ${PROFILE} --bucket "${BUCKET}"
# shellcheck disable=SC2086
aws s3api get-bucket-versioning ${PROFILE} --bucket "${BUCKET}"
# shellcheck disable=SC2086
aws s3api get-bucket-encryption ${PROFILE} --bucket "${BUCKET}"

# sed for account id and bucket.
cat "${SCRIPT_DIR}"/files/aws/terraform_state_policy.template.json | sed -e "s/##AWS_ID##/${AWS_ID}/g" > "${SCRIPT_DIR}"/files/aws/terraform_state_policy.json
cat "${SCRIPT_DIR}"/files/aws/terraform_state_policy.json | sed -i -e "s/##BUCKET##/${BUCKET}/g" "${SCRIPT_DIR}"/files/aws/terraform_state_policy.json
# shellcheck disable=SC2086
aws s3api put-bucket-policy ${PROFILE} --bucket "${BUCKET}" --policy file://"${SCRIPT_DIR}"/files/aws/terraform_state_policy.json
rm -f "${SCRIPT_DIR}"/files/aws/terraform_state_policy.json

echo "--------------------------------------------------------------"
echo "bucket_name: ${BUCKET}"
echo "region: ${REGION}"
echo "--------------------------------------------------------------"
