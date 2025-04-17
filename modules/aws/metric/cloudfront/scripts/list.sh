#!/bin/bash
set -e

list_distribution=($(aws cloudfront list-distributions | jq -r '.DistributionList.Items[]' | jq -r '.Id'))
list_domain=($(aws cloudfront list-distributions | jq -r '.DistributionList.Items[]' | jq -r '.Aliases.Items[0]'))
echo -n '{'

echo -n '"list_distribution": "'
for data in "${list_distribution[@]::${#list_distribution[@]}-1}"
do
  echo -n "$data,"
done
echo -n "${list_distribution[@]: -1:1}\","

echo -n '"list_domain": "'
for data in "${list_domain[@]::${#list_domain[@]}-1}"
do
  echo -n "$data,"
done
echo -n "${list_domain[@]: -1:1}\""

echo '}'
