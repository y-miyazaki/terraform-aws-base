#/bin/bash
set -e
#--------------------------------------------------------------
# recursive check
#--------------------------------------------------------------
for file in `find /workspace/ ! -path '*/.terraform/*' -type f -name 'main.tf'`; do
    dir=`dirname $file`
    cd ${dir}
    pwd
    tfenv install
    terraform init -backend=false
    terraform validate
    tflint
    terraform-docs markdown --output-file README.md ./
done
trivy fs . --format table
