#!/bin/bash

# タスク定義のリストを取得
task_definitions=$(aws ecs list-task-definitions --output json | jq -r '.taskDefinitionArns[]')

# 一意のタスク定義ファミリーを格納する配列
unique_families=()

# 結果を出力
echo "["
for task_definition in $task_definitions; do
  # タスク定義ファミリーを抽出
  family=$(echo $task_definition | awk -F'/' '{print $NF}' | awk -F':' '{print $1}')

  # ファミリーが既に配列に存在しない場合のみ追加
  if [[ ! " ${unique_families[@]} " =~ " ${family} " ]]; then
    unique_families+=("$family")

    echo "  {"
    echo "    ClusterName = \"\""
    echo "    TaskDefinitionFamily = \"$family\""
    echo "  },"
  fi
done
echo "]"
