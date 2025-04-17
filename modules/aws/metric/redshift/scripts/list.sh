#!/bin/bash
set -e

list=($(aws redshift describe-clusters | jq -r '.Clusters[].ClusterIdentifier'))
echo -n '{'

echo -n '"list": "'
for data in "${list[@]::${#list[@]}-1}"
do
  echo -n "$data,"
done
echo -n "${list[@]: -1:1}\""

echo '}'
