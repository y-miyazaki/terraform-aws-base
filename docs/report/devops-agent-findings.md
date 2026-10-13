# AWS DevOps Agent 調査レポート: 仕様と運用上の知見

`terraform/monitor`（モジュール `modules/aws/devops_agent`）で DevOps Agent を構成する過程で分かったことをまとめる。

- 作成日: 2026-10-12
- 対象: Agent Space、Skill、カスタム Agent、Webhook、MCP サーバー、Slack 返信、GitHub 連携
- 凡例: **確認済み**＝ドキュメントまたは Terraform 検証、または DevOps Agent 自身の回答で確認。**未確認**＝実機（dev への apply）で未検証。

## 1. 要約

- 調査のきっかけ（Webhook）で DevOps Agent に渡るのは、タイトル、説明、優先度、インシデント参照だけである。`data` は無視される。Slack の返信先などは、説明（`description`）の末尾に入れる必要がある。
- Skill は調査リードとサブエージェントで見え方が異なる。サブエージェントは調査リードの prompt に書かれた内容しか知らない。このため、Slack 返信の欠落が起きた。
- カスタム Agent は、Webhook で起動する調査（調査リード）には効かない可能性が高い。実際に効くのは Skill である。
- GitHub MCP にはラベル作成専用のツールが無い。ラベルは `issue_write` の `labels` で付ける。PR への付与は `issue_write` に PR 番号を渡す方法が唯一で、実機では未確認である。
- Incident URL の形式は文書化されていない。取得できないときは `unknown` と書く。

## 2. 構成要素

### 2.1 Agent Space と Skill

| 項目                   | 内容                                                                                                              | 状態   |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------- | ------ |
| Skill の登録           | `awscc_devopsagent_asset`（`asset_type=skill`）。`files` に複数のパスを渡せる                                     | 確認済 |
| frontmatter            | 単一ファイルの登録では不要（名前と説明は metadata で渡す）。zip でのアップロードでは必要                          | 確認済 |
| description            | 1〜1024 文字。100 文字以上を推奨。「Use this when…」の形で、使う場面を書く                                        | 確認済 |
| 上限                   | zip は 6 MB、ファイルは 100 個以下、Skill は 200 個まで                                                           | 確認済 |
| スクリプト             | 非対応                                                                                                            | 確認済 |
| 複数ファイルの読み込み | `references/` や `assets/` を Agent が実際に開くか、`awscc` リソースが複数 `files` を受け付けるかは、実機で未確認 | 未確認 |

### 2.2 カスタム Agent

- 定義は `AGENT.md`、`tools`、スケジュールのトリガーで構成する。種別は GENERIC が既定である。
- `AGENTS.md` は 25 KB が上限で、120 行程度を推奨する。
- 定期実行の Agent は、調査とは別の実行（別のインボケーション）として動く想定である。DevOps Agent からは、この Agent の名前が見えなかった。実際に動くかは未確認である。

### 2.3 Webhook

- DevOps Agent に届くのは、タイトル、説明、優先度、インシデント参照だけで、`data` は無視される。
- Slack の返信先は、説明の末尾に次の1行として入れる（送信側の Lambda が付ける前提。実装は未確認）。

```text
slack_reply_target: channel_id=<channel id> thread_ts=<timestamp>
```

- 今回の調査では、`REFERENCE_URL` が空で、調査自身の incident ID も渡されなかった。

## 3. Skill の設計

### 3.1 ベストプラクティス（公式の指針）

- description に「Use this when…」を入れる。
- 手順は番号付きにし、判断の分岐と、進めない場合の逃げ道を書く。
- ほかの Skill が読み込まれている前提で書かない。
- Skill の内容が古くなるのを防ぐため、`last_verified` を残す。
- 役割が重なる Skill を作らない。

### 3.2 ディレクトリ構成

`.agents/skills` と同じ構成にした。

```text
<skill-name>/
  SKILL.md                      入力、出力、使う場面、参照ファイル、手順、エラー処理
  references/
    common-checklist.md         CHK-nn の ID 付きチェックリスト
    common-output-format.md     出力の形式
  assets/
    *.md                        Issue、PR、コメントなどのテンプレート
```

- ディレクトリ名は Skill 名と同じケバブケースにする。
- Terraform 側（`main_central_devops_agent.tf`）が、`content_file` と同じディレクトリの `{assets,references}/**` にあるテキストファイル（`csv`、`json`、`md`、`txt`、`yaml`、`yml`）を自動で添付する。
- モジュールの `skills.files` は、`references/` か `assets/` 配下のパスだけを許可する（入力の検証あり）。

### 3.3 現在の Skill

| Skill                      | 用途                                                                     |
| -------------------------- | ------------------------------------------------------------------------ |
| `github-issue-draft-pr`    | アラーム調査を GitHub Issue と Draft PR に記録し、Slack に返信する       |
| `notion-issue-draft-pr`    | 同じ内容を Notion のページと GitHub の Draft PR に記録する（dev は無効） |
| `github-issue-pr-followup` | ラベル付きの Issue/PR への人の返信を定期的に読み、対応する               |

## 4. 実行主体と Slack 返信

### 4.1 DevOps Agent 自身の回答で分かったこと

| 項目                         | 内容                                                                                                                        |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| 調査リード                   | ユーザー版の `github-issue-draft-pr` を読み込める。ただし、リードの仕事は調査であり、記録や整形は別の担当に任せる設計である |
| ミティゲーション版 Skill     | `/aidevops/skills/mitigation/` に同名のコピーがある。リードはこれを読まない。出どころや同期の有無は、リードからは見えない   |
| サブエージェント             | リードが書いた prompt しか文脈に持たない。説明の末尾の `slack_reply_target` は自動では渡らない                              |
| `preloaded_skills`           | generic 型のサブエージェントにだけ指定できる。ミティゲーション型には使えない                                                |
| ミティゲーション型の振る舞い | 提案で止まり、記録まで実行しないことがある（今回、実際に起きた）                                                            |
| カスタム Agent               | `github_issue_pr_agent` はリードから見えない                                                                                |
| Slack ツール                 | 投稿専用で、スレッドや履歴は読めない。確認できるのは、投稿時に返る `ok` と `ts` だけ                                        |
| 承認                         | Webhook 起動時の書き込み系ツールの人手承認は、定義に無く、不明。Slack への投稿は承認なしで成功した                          |

### 4.2 今回起きた欠落の原因

1. 返信の手順が Skill の Workflow にしか無く、調査リードには、返信A（調査開始）を送る手順が無かった。
2. ミティゲーション用のサブエージェントに `proposing-mitigations` だけを渡したので、`github-issue-draft-pr` が実行されなかった。
3. サブエージェントには `slack_reply_target` が渡らないので、実行されても返信は無言でスキップされる状態だった。

### 4.3 対応した定義

| 返信 | 送る担当                               | タイミング                                     |
| ---- | -------------------------------------- | ---------------------------------------------- |
| A    | 調査リード                             | 調査の開始時                                   |
| B    | Issue/ページと PR を作ったエージェント | Issue/ページと PR が確定した後（どの結果でも） |
| C    | 同上                                   | 人の判断が必要なときだけ、1回まで              |

- リードは、記録を任せるサブエージェントの prompt に、`slack_reply_target` の行、Incident の値、この Skill を最後まで実行する指示を転記する。
- 記録の委譲先は、`preloaded_skills` でこの Skill を読ませた generic 型のサブエージェントにする。現状もっとも確実な方法である。
- リードは Slack を読めないので、返信B は、サブエージェントが報告する `ok` と `ts` で確認する。Issue と PR は、GitHub の read 系ツールで自分で確認する。
- 返信の形式は `references/common-output-format.md` に定義した。

## 5. GitHub 連携

### 5.1 ツール名

| 用途               | ツール                                                                                       |
| ------------------ | -------------------------------------------------------------------------------------------- |
| Issue の作成と更新 | `issue_write`（`labels`、`state`、`state_reason` を指定できる）                              |
| Issue の読み取り   | `issue_read`（`get`、`get_comments`、`get_labels`）、`search_issues`、`list_issues`          |
| コメント           | `add_issue_comment`（PR にも使える）                                                         |
| PR                 | `create_pull_request`、`update_pull_request`、`pull_request_read`                            |
| ブランチとファイル | `create_branch`、`create_or_update_file`、`push_files`、`get_file_contents`、`list_branches` |
| ラベルの確認       | `get_label`、`list_label`                                                                    |

- DevOps Agent から見えたツール名の接頭辞は、`GitHubMcpServer_` と `McpSlackReply_` だった。
- `label_write` は、DevOps Agent のツール群には無かった。

### 5.2 ラベル `devops-agent`

- ラベルの作成専用ツールは無い。`issue_write` の `labels` で付ける。
- 存在しないラベルを Issue 作成時に渡すと、GitHub の API の仕様では自動で作られる（DevOps Agent の回答）。MCP サーバー経由で同じに動くかは、未確認である。
- PR には `labels` を受け取るツールが無い。`issue_write`（`method: update`、`issue_number` に PR 番号、`labels`）が、付ける唯一の方法である。実機では未確認である。
- 失敗したら、再試行せず、PR のコメントと返信B で報告する。

### 5.3 コメントの検知

- 公式の GitHub 連携は、コメントのイベントを DevOps Agent に渡さない。このため、ラベル付きの Issue/PR を定期的に読む、スケジュール実行の Agent（`github_issue_pr_followup_agent`）で補う。
- 未回答の人のコメントは、自分のコメントの末尾にある `-- devops-agent` の行より新しく、投稿者が人（author type が `User`）のものとして判定する。
- Issue を閉じる条件は、人が閉じるよう明示した場合、または、紐づく PR がマージされた場合である。PR を閉じるのは、人が明示した場合だけである。マージ、承認、再オープンはしない。

## 6. リンクの形式

| 項目     | 形式                                                                                                   |
| -------- | ------------------------------------------------------------------------------------------------------ |
| Incident | 自分の文脈から読めるなら、Web アプリの調査 URL。なければ `incidentId=<id>`。どちらも無ければ `unknown` |
| Issue    | ツールが返す `html_url` の全体                                                                         |
| PR       | ツールが返す `html_url` の全体と、状態（`Draft`、`open`、`merged`、`closed`）                          |
| 無い項目 | `none (<理由>)`                                                                                        |

- Incident URL の形式は文書化されていない。URL を組み立てたり、ID を推測したりしない。関連する調査の ID の流用も不可である。

## 7. 未確認の事項と次の確認

| 項目                                                         | 確認方法                                         |
| ------------------------------------------------------------ | ------------------------------------------------ |
| 複数ファイルの Skill（`references/`、`assets/`）が読まれるか | dev に apply して、調査を1件実行する             |
| ミティゲーション版 Skill の出どころ、同期                    | apply 後に、両方の本文を読み比べる               |
| 調査リードにカスタム Agent が効くか                          | 調査を実行して、返信A が開始時に送られるかを見る |
| 定期実行の Agent が動くか                                    | 実行履歴と、ラベル付き Issue へのコメントを見る  |
| PR へのラベル付与（`issue_write` に PR 番号）                | Draft PR を作って、ラベルが付くかを見る          |
| 存在しないラベルの自動作成（MCP 経由）                       | 新規の Issue を作って、ラベルが作られるかを見る  |
| Webhook 送信 Lambda が `slack_reply_target` を付けるか       | Lambda の実装を確認する                          |
| Webhook 起動時の書き込み系ツールの承認                       | 調査を実行して、承認の有無を見る                 |
| Incident URL の形式と、取得できる変数                        | 調査画面の URL と、リードが読める値を確認する    |
| `terraform plan`、`terraform fmt`、markdownlint              | 認証情報のある環境で実行する                     |

## 8. 関連ドキュメント

- [Monitor Features Detail](../reference/features-monitor.md)（Skill の構成、ラベル、Slack 返信の形式、定期フォローアップ）
- [Monitor Terraform Configuration Guide](../how-to/configure-monitor-tfvars.md)
- [Slack Reply MCP Lambda Request](../reference/mcp-slack-reply-lambda-request.md)
