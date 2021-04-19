#/bin/bash
set -e
#--------------------------------------------------------------
# recursive check
#--------------------------------------------------------------
for file in `find /workspace/ -name "main.tf" -type f`; do
    dir=`dirname $file`
    cd ${dir}
    pwd
    terraform init -backend=false
    terraform validate
    tflint
    tfsec
done
