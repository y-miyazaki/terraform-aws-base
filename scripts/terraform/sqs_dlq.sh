#!/bin/bash

# DLQリスト取得
queue_arns=$(aws sqs list-queues | jq -r '.QueueUrls[]' | xargs -I {} aws sqs get-queue-attributes --queue-url {} --attribute-names RedrivePolicy | jq -r '.Attributes.RedrivePolicy' | jq -r '.deadLetterTargetArn')

# 一意のDLQを格納する配列
dlqs=()

# 結果を出力
echo "["
for queue_arn in $queue_arns; do
  # DLQを抽出
  name=$(echo $queue_arn | awk -F':' '{print $NF}' | awk -F':' '{print $1}')

  # DLQが既に配列に存在しない場合のみ追加
  if [[ ! " ${dlqs[@]} " =~ " ${name} " ]]; then
    dlqs+=("$name")

    echo "  {"
    echo "    QueueName = \"$name\""
    echo "  },"
  fi
done
echo "]"
