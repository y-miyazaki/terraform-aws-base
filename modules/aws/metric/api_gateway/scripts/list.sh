#!/bin/bash
set -e

list=($(aws apigateway get-rest-apis | jq -r '.items[].name'))
echo -n '{"list": "'
for data in "${list[@]::${#list[@]}-1}"
do
  echo -n "$data,"
done
echo -n "${list[@]: -1:1}"
echo '"}'
