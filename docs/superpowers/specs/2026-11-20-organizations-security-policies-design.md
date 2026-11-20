# Organizations ポリシーによるセキュリティサービス管理への移行 設計

- 作成日: 2026-11-20
- 状態: ドラフト（承認待ち）
- 対象スタック: `terraform/management/root`、`terraform/management/audit`
- 範囲外: コスト試算（利用者が別途実施）

## 1. 意図と背景

Security Hub CSPM の中央設定ポリシーの関連付けが、無効化されたオプトインリージョン（`me-south-1`）のせいで FAILED になった。その結果、無効化したはずの `IAM.28` が残った。

これをきっかけに、セキュリティサービスの管理の仕方を見直す。

- 現状: Security Hub、GuardDuty、Inspector の組織設定は、Audit の Terraform の中で、サービスごとに別々の仕組みで持っている。
  - Security Hub: 中央設定ポリシー
  - GuardDuty: 自動有効化と機能の設定
  - Inspector: 自動有効化と enabler
- AWS の動向: Security Hub が V2 に統合され、各サービスの組織設定は AWS Organizations のポリシー（declarative policy）で一元管理する方向にある。
  - ポリシーの種類: `SECURITYHUB_POLICY`、`SECURITYHUB_CSPM_POLICY`、`GUARDDUTY_POLICY`、`INSPECTOR_POLICY`
- 方針: 今後増えるセキュリティ系ポリシーを含めて、**Audit（委任管理者）を管理主体に、Organizations のポリシーとして一括管理する**形に移行する。

## 2. ゴール、非ゴール、アンチゴール

### ゴール

- Security Hub（V2）、Security Hub CSPM、GuardDuty、Inspector の組織への有効化と設定を、Organizations のポリシーで管理する。
- ポリシーは Audit（委任管理者）が作成し、アタッチする。root（管理アカウント）の作業は、委任ポリシーなどの土台に限る。
- 可能な限り Terraform で管理する。provider が未対応のものは、対応後に Terraform へ取り込む。
- 組織への影響が小さい順に、段階的に移行する。

### 非ゴール

- タグポリシーの管理。値も大文字小文字も縛らない方針のため、得られる効果がない。
- SCP（Control Tower の `aws-guardrails-*`、独自の `security-ou-region-deny`、`DenyAllActions`）の Terraform 管理。
- Macie と Access Analyzer の管理方式の変更。対応するポリシータイプがないので、Audit の Terraform に残す。
- コスト試算。

### アンチゴール（技術的に動いても失敗とみなす状態）

- 移行の途中で、既存アカウントの GuardDuty、Inspector、Security Hub が無効になる。
- 意図しない段階で、CSPM の中央設定が組織全体で止まる。
- ap-northeast-3 で、許可リストにないアカウントにサービスを有効化しようとして、失敗や異常な状態になる。
- 検知の通知（Slack）が、移行の途中で黙って止まる。
- Terraform と実環境の間に、恒常的な差分が残る。

## 3. 現状（2026-11-20 時点で確認した事実）

| 項目                                         | 状態                                                                                                                                                                                                                                                                                              |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Organizations のルートで有効なポリシータイプ | `SERVICE_CONTROL_POLICY`、`TAG_POLICY` のみ                                                                                                                                                                                                                                                       |
| タグポリシー                                 | 0 件                                                                                                                                                                                                                                                                                              |
| 委任ポリシー                                 | 既存の委任ポリシーが 1 件存在する（Terraform 管理外）。Audit に対して、`inspector_policy` の Create/Update/Delete/Attach/Detach、`EnablePolicyType`/`DisablePolicyType`、Describe/List 系、タグ操作を許可している。Sid の名前から、Inspector コンソールで自動生成されたものと推測される（未確認） |
| root の Terraform                            | `aws_organizations_*` のリソースはない                                                                                                                                                                                                                                                            |
| CSPM                                         | Audit の Terraform（`modules/aws/security/securityhub_organization`）が、中央設定ポリシー `base-securityhub-configuration-policy` をルートに関連付けている。集約リージョンは `SPECIFIED_REGIONS`（`region.targets` から home を除いたもの）に修正済み                                             |
| GuardDuty                                    | `modules/aws/security/guardduty_organization` がリージョンごとに、`auto_enable_organization_members`（allowlist があるリージョンは `NONE`）、`features`、`members` を管理している                                                                                                                 |
| Inspector                                    | `modules/aws/security/inspector2_organization` がリージョンごとに、enabler、member association、organization configuration を管理している。`region_excluded_resource_types` で、ap-northeast-3 の `LAMBDA_CODE` と `CODE_REPOSITORY` を除外している                                               |
| 対象リージョン                               | `region.targets` = ap-northeast-1（primary/home）、ap-northeast-3、us-east-1                                                                                                                                                                                                                      |
| ap-northeast-3                               | `region.account_allowlist` に登録したアカウントだけを有効化する（それ以外の OU は SCP で拒否される）                                                                                                                                                                                              |
| 通知                                         | Security Hub は EventBridge（ASFF）→ Step Functions → SNS → Chatbot。GuardDuty と Access Analyzer は EventBridge → SNS → Chatbot                                                                                                                                                                  |
| provider                                     | hashicorp/aws 6.73.0（最新リリース）。全スタックの lock ファイルで固定済み                                                                                                                                                                                                                        |

## 4. 制約

### Terraform の provider（6.73.0）

- `aws_organizations_policy` の `type` は、`GUARDDUTY_POLICY`、`INSPECTOR_POLICY`、`SECURITYHUB_POLICY` に対応している。`SECURITYHUB_CSPM_POLICY` は**未対応**。
  - SDK の organizations v1.63.0 で追加され、provider の SDK 更新 PR #51075 が未マージの状態。
  - tflint-ruleset-aws の `aws_organizations_policy_invalid_type` ルールも未対応。
- ポリシータイプをルートで有効化する単独のリソースはない。`aws_organizations_organization` の `enabled_policy_types` しかないが、Control Tower の組織を import することになり、影響範囲が大きい。関連する未修正のバグもある（#50386、#50387）。
- `aws_organizations_resource_policy` は組織に 1 つだけのリソースで、import の ID は `rp-xxxx`。
- Security Hub V2 用に、`aws_securityhub_account_v2`、`aws_securityhub_aggregator_v2`、`aws_securityhub_automation_rule_v2`、`aws_securityhub_feature_v2` が使える。
  - `aws_securityhub_organization_admin_account` には `feature` 引数がない。ただし、CSPM の委任管理者（Audit）は自動的に V2 の委任管理者にもなる。

### AWS の挙動（AWS ドキュメントより）

- **CSPM**:
  - CSPM ポリシーが 1 つでもアカウントを管理対象にすると、組織全体の中央設定が無効になる。例外は、アカウントのない OU へのアタッチ。
  - 移行は、コンソールの import ツール（Security Hub V2 コンソールの Management → Configurations）経由が推奨されている。
  - 中央設定が止まった後も、`UpdateFindingAggregator` は使える。
  - CSPM ポリシーでは、集約リージョン、AWS Config、Control Tower のサービス管理標準は扱えない。
  - 管理アカウントに `AWSServiceRoleForSecurityHub` が必要。
- **GuardDuty**:
  - `GUARDDUTY_POLICY` タイプを**有効にした時点で**、リージョンごとの自動有効化の設定が効かなくなる（ポリシーをアタッチしたかどうかに関係なく）。タイプを無効にすると、元に戻る。
  - 子ポリシーで使える演算子は `@@assign` のみ。リージョンのブロックは、`default` を上書きする（マージされない）。
  - 委任管理者の登録は、リージョンごとに必要なまま。IP リストや抑制ルールは、ポリシーの対象外。
  - 管理アカウントに GuardDuty のサービスリンクロールがないと、ポリシーでは有効化できない。
- **Inspector**: ポリシーで管理されているリソースは、委任管理者もメンバーも変更できない。スキャン設定（EC2 のスキャンモードなど）は、引き続き変更できる。
- **外したとき（共通）**: ポリシーを外しても、各サービスは**有効のまま残る**。止まるのは、新しいアカウントへの自動有効化だけ。
- **リージョンの範囲**: `ALL_SUPPORTED` や GuardDuty の `default` ブロックは、全リージョンが対象になる。SCP で禁止しているリージョンや、無効なオプトインリージョンでの動作は、**未確認**。
- **V2 を有効にしたとき**: サービスリンク型の Config レコーダーと、サービスリンク型の Access Analyzer が作られる。Control Tower の Config レコーダーとの関係は、**未確認**。
- **管理アカウントへの影響**: GuardDuty 以外のポリシーが管理アカウントに効くかは、**未確認**。

### Control Tower

- Control Tower が作ったリソース（`aws-guardrails-*` の SCP など）は変更しない。
- 独自のポリシーは「Control Tower の外」で実装するのが、AWS の推奨パターン。今回の設計はこれに該当する。

## 5. 検討したアプローチ

| 案            | root の Terraform                                   | ポリシータイプの有効化           | ポリシーの作成                                                                              | 評価                                                                                                                                   |
| ------------- | --------------------------------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **1（採用）** | 委任ポリシーのみ                                    | 1 回限りの手作業（手順書に記載） | Audit の Terraform。CSPM はコンソールで import し、provider の対応後に Terraform へ取り込む | Terraform で管理できる範囲が最大で、影響範囲が最小                                                                                     |
| 2             | 組織全体を import し、`enabled_policy_types` を管理 | Terraform                        | Audit の Terraform                                                                          | Control Tower の組織を Terraform に取り込むと、信頼されたアクセスの一覧のずれや既知のバグ 2 件があり、効果に対して影響範囲が大きすぎる |
| 3             | 委任ポリシーのみ                                    | V2 コンソールが自動で有効化      | Audit の V2 コンソール                                                                      | ポリシーが Terraform の外に出て、設定の変化が見えなくなる。一括管理の意図に反する                                                      |

利用者は、案 1 をベースに「組織への影響が小さい順に進める」ことを選んだ。タグポリシーは、効果がないため対象から外した。

## 6. 決定事項

### 6.1 管理主体の分担

| 対象                                                                                                              | 管理する場所                               | 方法                                                                           |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------ |
| 委任ポリシー（`aws_organizations_resource_policy`）                                                               | root の Terraform                          | 既存の委任ポリシー（`rp-xxxxxxxx`）を import して拡張する                      |
| ポリシータイプの有効化                                                                                            | 管理アカウント（または委任された Audit）   | 1 回限りの CLI 作業。手順書に記載する                                          |
| `SECURITYHUB_POLICY`、`INSPECTOR_POLICY`、`GUARDDUTY_POLICY`                                                      | Audit の Terraform                         | `aws_organizations_policy` と `aws_organizations_policy_attachment`            |
| `SECURITYHUB_CSPM_POLICY`                                                                                         | Audit。当面はコンソール                    | import ツールで作成する。provider と tflint の対応後に `terraform import` する |
| 委任管理者の登録、GuardDuty の detector、集約リージョン（CSPM と V2）、自動化ルール、通知、Macie、Access Analyzer | Audit の Terraform（現状維持、または追加） | ―                                                                              |

### 6.2 リージョンと ap-northeast-3 の扱い

- `ALL_SUPPORTED` と GuardDuty の `default` ブロックは**使わない**。リージョンは明示して列挙する。
- ルートにアタッチするベースのポリシーは、`region.targets` から allowlist があるリージョンを除いたリージョンを対象にする。
- allowlist があるリージョン（ap-northeast-3）は、**許可リストのアカウントにだけアタッチする追加ポリシー**で有効化する。
- ポリシーの内容は、既存の `region.targets` と `region.account_allowlist` から導出する。新しい tfvars の変数は、できるだけ増やさない。
- 無効化の一覧（`disable_in_regions` や `disabled`）に、使わないリージョンを入れない。ポリシーで無効化すると、対象アカウントでは再有効化できなくなるため。

### 6.3 Terraform からの切り離し方

- ポリシーに置き換わるリソースは、`removed { lifecycle { destroy = false } }` で state から外す。destroy すると、サービスの無効化や設定の削除が実行されてしまうため。

### 6.4 段階計画

各段階は、別々の PR とデプロイにする。次の段階に進む前に、前の段階の検証が終わっていることを条件にする。

#### 段階 1: 委任ポリシーを Terraform に取り込む（組織への影響なし）

- root スタックに `aws_organizations_resource_policy` を追加し、既存の委任ポリシー（`rp-xxxxxxxx`）を import する。
- 最初の apply は、**既存の内容と同じ**にする（plan の差分が 0 になることを確認する）。
- 次に、`securityhub_policy` と `guardduty_policy` の分を追加する。既存の `inspector_policy` 分と同じ構造で、ポリシーの ARN パスと `organizations:PolicyType` 条件を追加する。
- `securityhub_cspm_policy` 分は、段階 5 で追加する。
- Audit のアカウント ID は、既存の変数か data source から取得する。ハードコードはしない。

#### 段階 2: Security Hub V2（追加のみ）

- **PoC（Audit のみ、本番の切り替え前）**:
  1. V2 を有効にした後も、既存の CSPM の通知（ASFF の EventBridge → Step Functions → Chatbot）が届き続けるかを確認する。
  2. サービスリンク型の Config レコーダーが、Control Tower の Config と衝突しないかを確認する。
  3. 必要になるポリシータイプの有効化の手順を確認する。
- Audit の Terraform:
  - home リージョンに `aws_securityhub_account_v2` を追加する。
  - `aws_securityhub_aggregator_v2` を追加する（`SPECIFIED_REGIONS`、`linked_regions` は CSPM の集約と同じ導出）。
  - `SECURITYHUB_POLICY` のベースのポリシーをルートにアタッチする。ap-northeast-3 用の追加ポリシーは、許可リストのアカウントにアタッチする。
- `network_scanning` は有効にしない。必要になったら別途判断する。
- 既存の CSPM と通知は、変更しない。

#### 段階 3: Inspector

- `INSPECTOR_POLICY` を作成する。
  - スキャン種別ごとの `enable_in_regions` は、`enabler.resource_types` と `region_excluded_resource_types` から導出する。
  - ap-northeast-3 は、許可リストのアカウント向けの追加ポリシーで扱う。
- ポリシーの有効性を確認した後、`inspector2_organization` モジュールの enabler、member association、organization configuration を `removed`（destroy=false）で外す。
- 委任管理者の登録は残す。

#### 段階 4: GuardDuty

- 順序: ポリシーを Terraform で用意する → ポリシータイプを有効化する → すぐにアタッチする。
  - タイプを有効にしてからアタッチするまでの間は、新しく入ったアカウントだけが自動で有効化されない。既存アカウントは有効のまま。
- 機能の対応: 既存の `guardduty_organization.features` を、ポリシーのキーに変換する。

  | 既存の features          | ポリシーのキー                                            |
  | ------------------------ | --------------------------------------------------------- |
  | （GuardDuty 本体）       | `foundational`                                            |
  | `S3_DATA_EVENTS`         | `s3_data_events`                                          |
  | `EKS_AUDIT_LOGS`         | `eks_audit_logs`                                          |
  | `EBS_MALWARE_PROTECTION` | `ebs_malware_protection`                                  |
  | `RDS_LOGIN_EVENTS`       | `rds_login_events`                                        |
  | `LAMBDA_NETWORK_LOGS`    | `lambda_network_logs`                                     |
  | `RUNTIME_MONITORING`     | `runtime_monitoring`（`additional_configuration` を含む） |

- `default` ブロックは使わず、リージョンのブロックだけを書く。
- `aws_guardduty_organization_configuration`、`_feature`、`aws_guardduty_member` を `removed`（destroy=false）で外す。
- 委任管理者の登録（全リージョン）と detector は残す。

#### 段階 5: CSPM（組織全体の中央設定が止まる）

- 前提: 段階 2 の PoC が終わっていること。管理アカウントに `AWSServiceRoleForSecurityHub` があること。
- 手順:
  1. 段階 1 の委任ポリシーに、`securityhub_cspm_policy` 分を追加する。
  2. Audit の V2 コンソールで、中央設定ポリシーを import する（ポリシー名は `{ID}_{元の名前}`）。
  3. `securityhub_organization` モジュールの `aws_securityhub_configuration_policy`、`_association`、`aws_securityhub_organization_configuration` を `removed`（destroy=false）で外す。
  4. `aws_securityhub_finding_aggregator` と委任管理者の登録は残す。
- import ツールの仕様で、委任管理者（Audit）自身は self-managed になる。
- provider と tflint が `SECURITYHUB_CSPM_POLICY` に対応した後に、import されたポリシーを Terraform に取り込む。`disabled_control_identifiers`（tfvars）をポリシーの内容に移す。
- 取り込みは別の PR とする。

### 6.5 検証と切り戻し（全段階に共通）

- **検証**:
  - 代表的なアカウントとリージョンで、`DescribeEffectivePolicy` を確認する。
  - 各サービスの有効状態を確認する（Security Hub、GuardDuty の detector と機能、Inspector のスキャン種別）。
  - ap-northeast-3 で、許可リストにないアカウントが対象外になっていることを確認する。
- **切り戻し**:
  - ポリシーを外すと、サービスは有効のまま残る。
  - GuardDuty は、ポリシータイプを無効にすると、リージョンごとの自動有効化が元に戻る。ただし、`removed` で外したリソースの再取り込みが必要になる。
  - CSPM は、全ポリシーを外してから `UpdateOrganizationConfiguration(CENTRAL)` を実行すると、中央設定に戻せる。

### 6.6 テストとドキュメント

- 新しいモジュールには、`terraform test`（mock_provider）を付ける。ポリシーの JSON の内容（リージョンの導出、ap-northeast-3 の分割、機能の変換）を検証する。
- ドキュメントを更新する: `docs/how-to/configure-management-audit-tfvars.md`、`configure-management-root-tfvars.md`、各モジュールの README。ポリシータイプ有効化の手順書を追加する。

## 7. 未確認事項（実装前または PoC で確認する）

1. `ALL_SUPPORTED`、`default`、明示したリージョンが、SCP で禁止しているリージョンや無効なオプトインリージョンでどう動くか。明示したリージョンなら、影響を受けない想定。
2. 子ポリシーを継承したときの結果（リージョンのキーを足す追加ポリシーが、ベースとどうマージされるか）。サービスごとに `DescribeEffectivePolicy` で確認する。
3. 管理アカウントに、各ポリシーが効くか。
4. V2 のサービスリンク型 Config レコーダーと、Control Tower の Config との関係。
5. V2 を有効にした後も、ASFF の EventBridge イベントが今まで通り出るか。V2 の OCSF 形式（`Findings Imported V2`）の通知に移行する必要があるか。
6. 委任ポリシーのリソース ARN パスのうち、新しいタイプの分（`securityhub_policy`、`guardduty_policy`、`securityhub_cspm_policy`）の正確な表記。
7. 既存の `aws_inspector2_organization_configuration` が、ポリシーとどう優先されるか（外すまでの共存期間に問題がないか）。

## 8. 実装者に任せる事項

- モジュールの分け方とファイル名（命名規約 `main_<scope>_<feature>.tf` に従う）。
- `import` ブロックと `removed` ブロックの書き方。
- ポリシーの JSON を組み立てる locals の構造。
- テストケースの具体的な内容。
- 手順書の置き場所（`docs/how-to/` 配下）。

## 9. 既知の課題（範囲外。記録のみ）

- `docs/how-to/configure-management-root-tfvars.md` の SCP の例（`AllowSpecificRegions`）が、実際のコードにない。しかも、Control Tower のガイドにある「SCP でリージョンを禁止しない」に反する例になっている。
- `terraform/management/audit/terraform.audit.tfvars` では `IAM.28` が有効だが、`terraform.example.tfvars` ではコメントアウトされていて、両者が一致していない。
- SCP（`security-ou-region-deny`、`DenyAllActions`）が Terraform の管理外にある。

## 10. レビューを受けて決めた事項（設計者の判断）

利用者が確認していない判断。異論があれば修正する。

- **ポリシータイプの有効化は Audit から実行する**: 既存の委任ポリシーには、`EnablePolicyType` と `DisablePolicyType` がすでに含まれている。段階 1 で、新しいポリシータイプにもこの権限が及ぶことを確認する（不足していれば追加する）。理由は 2 つ。管理主体を Audit に寄せられること。GuardDuty の切り戻し（ポリシータイプの無効化）も Audit で完結すること。
- **ap-northeast-3 の追加ポリシーがベースのポリシーとマージされない場合**: 許可リストのアカウントごとに、ap-northeast-3 を含む完全なポリシーをアタッチする方式に切り替える。許可リストはもともとアカウント単位なので、構造の変更は導出のロジックに閉じる。どちらの方式にするかは、各段階の最初に `DescribeEffectivePolicy` で確かめてから決める。
- **GuardDuty で今 `auto_enable = "NONE"` の機能**（`EKS_AUDIT_LOGS`、`RUNTIME_MONITORING` の `EKS_ADDON_MANAGEMENT`）: ポリシーには書かない（管理しない）。無効として書くと、アカウント側で有効にできなくなり、今の「任意で有効化できる」挙動が変わってしまうため。
