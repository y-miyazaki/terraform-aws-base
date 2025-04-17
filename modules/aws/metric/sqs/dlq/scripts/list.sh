#!/bin/bash
set -e

list=($(aws sqs list-queues | jq -r '.QueueUrls[]' | xargs -I {} aws sqs get-queue-attributes --queue-url {} --attribute-names RedrivePolicy | jq -r '.Attributes.RedrivePolicy' | jq -r '.deadLetterTargetArn'))
echo -n '{"list": "'
for data in "${list[@]::${#list[@]}-1}"
do
  echo -n "$data,"
done
echo -n "${list[@]: -1:1}"
echo '"}'
