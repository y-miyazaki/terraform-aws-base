# JIT Access System Specification

This document defines behavioral guarantees, operational expectations,
configuration behavior, and implementation constraints for the JIT (Just-In-Time)
privileged access system with Slack integration.

## Scope

| Item         | Detail                                                                 |
| ------------ | ---------------------------------------------------------------------- |
| Features     | Slack-based request, approval workflow, time-bound access, auto-revoke |
| Environments | Production                                                             |
| Exclusions   | Multi-account federation, audit reporting (v2)                         |

Out-of-scope items:

- Multi-account orchestration (single account per profile)
- Audit report generation (S3 + Athena planned for v2)
- Delegated approval (proxy approvers)

## System Responsibilities

- Accept JIT access requests via Slack slash command or Workflow Builder webhook
- Route approval notifications to a designated Slack channel
- Assign IAM Identity Center Permission Sets for approved requests at the specified start time
- Automatically revoke Permission Set assignments after the requested duration
- Provide a safety net via periodic cleanup of stale or orphaned assignments

### Ownership Boundaries

| Component          | Owner                         |
| ------------------ | ----------------------------- |
| Slack App config   | Platform team                 |
| Permission Sets    | Security team                 |
| Profile definition | Platform team (via Terraform) |
| User mapping       | Platform team (via Terraform) |

### External Dependencies

- AWS IAM Identity Center (SSO)
- AWS Identity Store
- Slack API (Bot Token, Signing Secret)
- AWS Systems Manager Parameter Store

## Behavioral Guarantees

### Request Flow

```text
Slack request -> Approval channel notification -> Approver clicks Approve
  -> Wait until start time -> Grant access -> Wait duration -> Revoke access
```

### Status Transitions

```text
pending -> approved -> active -> revoked       (normal completion)
pending -> approved -> active -> expired       (cleanup-checker forced revoke)
pending -> rejected                            (approver rejected)
pending -> auto_rejected                       (start time passed without approval)
active  -> revoked                             (early revocation)
```

### Invariants

- A user cannot have two active assignments for the same profile simultaneously
- Duration cannot exceed the profile's `max_duration_minutes`
- Only users listed in the profile's `approvers` can approve or reject
- All lifecycle events are posted as thread replies to the original approval message

### Failure Behavior

| Failure               | Behavior                                                     |
| --------------------- | ------------------------------------------------------------ |
| Grant Lambda failure  | 3 retries (30s, 60s, 120s backoff) -> GrantFailed state      |
| Revoke Lambda failure | 3 retries (30s, 60s, 120s backoff) -> DLQ + CloudWatch Alarm |
| Step Functions crash  | Cleanup checker scans every 15 min, force-revokes expired    |
| Unapproved past start | Cleanup checker auto-rejects pending requests                |

## Operational Characteristics

### Architecture

```text
┌─────────────────────────────────────────────────────────┐
│ Slack App                                               │
│  /jit-access (slash command)                            │
│  Modal -> Submit request                                │
│  Approve/Reject/Revoke buttons                          │
└────────────┬────────────────────────────────────────────┘
             │ (Slack signature verification)
             ▼
┌─────────────────────────┐
│ API Gateway (REST)      │
│  POST /slack/commands   │
│  POST /slack/interact   │
│  POST /workflow/request │
│  + WAFv2 Web ACL (opt)  │
└────────────┬────────────┘
             │ Immediate 200 -> async processing
             ▼
┌─────────────────────────┐
│ Lambda: jit-access      │
│  - Modal display        │
│  - Request submission   │
│  - Approval handling    │
│  - Early revocation     │
│  - Grant/Revoke actions │
│  - Cleanup check        │
└────────────┬────────────┘
             │
     ┌───────┴───────┐
     ▼               ▼
┌──────────┐  ┌──────────────────────────────────┐
│ DynamoDB │  │ Step Functions                    │
│ requests │  │  Wait until start                 │
│  table   │  │  -> Lambda: grant (action=grant)  │
└──────────┘  │  -> Wait(duration)                │
              │  -> Lambda: revoke (action=revoke) │
              └──────────────────────────────────┘

┌─────────────────────────────────────┐
│ Safety Net                          │
│ EventBridge Scheduler (every 15min) │
│  -> Lambda: cleanup (action=cleanup)│
│    - Scan stale active assignments  │
│    - Force-revoke expired           │
│    - Auto-reject unapproved past    │
│      start time                     │
└─────────────────────────────────────┘
```

### Scaling Expectations

- Single Lambda function handles all actions (routed by `action` parameter or HTTP event)
- DynamoDB on-demand billing (PAY_PER_REQUEST)
- Step Functions STANDARD type (one execution per approved request)
- API Gateway REST API with REGIONAL endpoint (chosen over HTTP API for WAFv2 support)

### Observability

- CloudWatch Logs for Lambda and Step Functions (ERROR level for SFn)
- CloudWatch Alarm on DLQ message count (revoke failure alert)
- All Slack notifications threaded under the approval message

## Configuration and Defaults

### Parameter Store Layout

| Parameter Path                               | Purpose                          |
| -------------------------------------------- | -------------------------------- |
| `/jit-access/config/approver-channel`        | Slack channel ID for approvals   |
| `/jit-access/config/state-machine-arn`       | Step Functions ARN               |
| `/jit-access/config/profiles/<profile-name>` | Profile configuration (JSON)     |
| `/jit-access/user-mapping/<slack-user-id>`   | Identity Center User ID fallback |

### Profile JSON Schema

```json
{
  "account_id": "123456789012",
  "permission_set_arn": "arn:aws:sso:::permissionSet/ssoins-xxx/ps-xxx",
  "max_duration_minutes": 240,
  "approvers": ["U111111", "U222222"],
  "description": "Production DB hotfix access"
}
```

### DynamoDB Table Design

**Table name:** `{name_prefix}jit-access-requests`

| Key    | Attribute       |
| ------ | --------------- |
| PK     | `request_id`    |
| GSI1PK | `slack_user_id` |
| GSI1SK | `created_at`    |
| GSI2PK | `status`        |
| GSI2SK | `start_at`      |

### Lambda Environment Variables

| Variable               | Source                     | Notes                           |
| ---------------------- | -------------------------- | ------------------------------- |
| `APPROVER_CHANNEL_ID`  | `var.slack`                | Approval notification channel   |
| `DYNAMODB_TABLE_NAME`  | DynamoDB module            | Requests table name             |
| `IDENTITY_CENTER_ARN`  | Data source                | Identity Center instance ARN    |
| `IDENTITY_STORE_ID`    | Data source                | Identity Store ID               |
| `SLACK_BOT_TOKEN`      | `var.slack`                | Bot OAuth token                 |
| `SLACK_SIGNING_SECRET` | `var.slack`                | Request signature verification  |
| `SSM_PARAMETER_PREFIX` | `var.ssm_parameter_prefix` | Default: `/jit-access`          |
| `WORKFLOW_SECRET`      | `var.slack`                | Optional; Workflow Builder auth |

## Slack UX

### Slash Command

`/jit-access` opens a modal with the following fields:

| Field              | Required | Description                                        |
| ------------------ | -------- | -------------------------------------------------- |
| Permission profile | Yes      | Dropdown (dynamically loaded from Parameter Store) |
| Start time         | No       | Unspecified = immediately after approval           |
| Duration           | Yes      | Selection: 30m / 1h / 2h / 4h (within profile max) |
| Reason             | Yes      | Free text                                          |
| Ticket number      | No       | Optional reference                                 |

### Approval Notification

Posted to the designated channel as a Block Kit message:

```text
JIT Access Request
Requester: @foo
Profile: prod-db-hotfix
Duration: 1h
Start: Immediately (or 2026-05-28 10:00 JST)
Reason: emergency migration
Ticket: INC-1234

[Approve] [Reject]
```

After approval, the message updates to show `[Revoke Now]` button.

### Notification Thread

All lifecycle events are posted as thread replies:

```text
[Parent] JIT Access Request (Approve/Reject buttons)
  └─ ✅ Approved by @approver (Revoke Now button)
  └─ 🔓 Access granted, expires at ...
  └─ 🔒 Access revoked
```

Error cases:

```text
  └─ ⏰ Auto-rejected (start time passed)
  └─ ⏹️ Early revoked by @actor
```

## User Mapping

### Resolution Order

1. Get Slack user's email via `users.info` API
2. Search Identity Center `ListUsers` for matching email
3. If no match, fall back to Parameter Store `/jit-access/user-mapping/{slack_user_id}`
4. If neither found, return error (notify via Slack)

### Fallback Registration

For users whose Slack email differs from their Identity Center UserName,
register a mapping in Parameter Store via Terraform `user_mappings` variable.

## Workflow Builder Integration

### Endpoint

`POST /workflow/request` (created only when `workflow_secret` is configured)

### Authentication

Request header: `x-workflow-secret: <WORKFLOW_SECRET>`

Generate a secure random string (e.g., `openssl rand -base64 32`) and set it
in both the Terraform `workflow_secret` variable and the Workflow Builder webhook step.

### Request Body

```json
{
  "slack_user_id": "U123456",
  "profile": "prod-db-hotfix",
  "duration": "60",
  "start_at": "2026-05-28T10:00:00+09:00",
  "reason": "emergency migration",
  "ticket": "INC-1234"
}
```

| Field         | Required | Description                                  |
| ------------- | -------- | -------------------------------------------- |
| slack_user_id | Yes      | Requester's Slack User ID                    |
| profile       | Yes      | Permission profile name                      |
| duration      | Yes      | Minutes as string ("30", "60", "120", "240") |
| start_at      | No       | Unspecified = immediately after approval     |
| reason        | Yes      | Justification                                |
| ticket        | No       | Ticket reference                             |

### Response

```json
{ "request_id": "20260528100000-U123456", "status": "pending" }
```

## Early Revocation

1. User clicks "Revoke Now" button in Slack
2. `StopExecution` stops the Step Functions execution
3. Lambda invoked directly with `action=revoke`
4. DynamoDB status updated to `revoked`
5. Slack thread notification posted

## Safety Design

| Risk                   | Mitigation                                                    |
| ---------------------- | ------------------------------------------------------------- |
| Revoke Lambda failure  | 3 retries -> DLQ -> CloudWatch Alarm -> Slack alert           |
| Step Functions crash   | Cleanup checker scans every 15 min, force-revokes expired     |
| Unauthorized request   | Slack signature verification + approvers list check           |
| Duration over-request  | Validated against profile `max_duration_minutes`              |
| Duplicate active grant | DynamoDB check for same user + same profile in active status  |
| Unapproved stale       | Cleanup checker auto-rejects pending requests past start time |

## Security

- Slack Signing Secret verification on all incoming requests
- 3-second rule: immediate `200` response, async processing via goroutine, result via `response_url`
- Only listed approvers can perform Approve/Reject actions
- Workflow Builder endpoint authenticated via shared secret header
- Bot token and signing secret stored as sensitive Terraform variables
- API Gateway uses REST API (not HTTP API) to support WAFv2 Web ACL association
- WAFv2 Web ACL association is optional (`waf_enabled` + `waf_web_acl_arn` variables)

## Terraform Module Structure

```text
modules/aws/jit_access/
  versions.tf       # required_version, provider constraints
  variables.tf      # module inputs
  main.tf           # all resources (DynamoDB, Lambda, API GW, SFn, Scheduler, DLQ, Alarm)
  outputs.tf        # module outputs
```

## Lambda Routing

Single Lambda function with action-based routing:

| Caller                                 | Action    | Processing                              |
| -------------------------------------- | --------- | --------------------------------------- |
| API Gateway (POST /slack/commands)     | HTTP auto | Slash command, modal display            |
| API Gateway (POST /slack/interactions) | HTTP auto | Approve/reject/early revoke             |
| API Gateway (POST /workflow/request)   | HTTP auto | Workflow Builder request submission     |
| Step Functions (GrantAccess)           | `grant`   | Permission Set assignment + polling     |
| Step Functions (RevokeAccess)          | `revoke`  | Permission Set removal + polling        |
| EventBridge Scheduler                  | `cleanup` | Stale scan + force revoke + auto-reject |

## AWS Services Used

- API Gateway (REST, REGIONAL endpoint)
- Lambda (Go, arm64)
- DynamoDB (on-demand)
- Step Functions (STANDARD)
- IAM Identity Center
- Systems Manager Parameter Store
- EventBridge Scheduler
- CloudWatch Alarms
- SQS (Dead Letter Queue)
- WAFv2 (optional, Web ACL association)
- KMS (optional, for encryption)

## Slack App Setup

Use the App Manifest output from Terraform to create and configure the Slack App.

### Prerequisites

- Terraform apply completed with `jit_access_slack_app_manifest` output available
- Admin permissions on the target Slack workspace

### 1. Get App Manifest from Terraform Output

```bash
terraform output -raw jit_access_slack_app_manifest
```

The output contains the API Gateway URLs pre-populated — no manual URL substitution required.

### 2. Create Slack App from Manifest

1. Go to [Slack App Management](https://api.slack.com/apps)
2. Click "Create New App" -> "From an app manifest"
3. Select target workspace
4. Paste the Terraform output YAML as-is
5. Review settings and click "Create"

### 3. Get Signing Secret

1. Navigate to "Basic Information" -> "App Credentials"
2. Copy **Signing Secret** -> set as Terraform `slack.signing_secret`

### 4. Install App and Get Bot Token

1. Navigate to "OAuth & Permissions" -> "Install to Workspace"
2. Authorize permissions
3. Copy **Bot User OAuth Token** (`xoxb-...`) -> set as Terraform `slack.bot_token`

### 5. Invite Bot to Channel

Invite the bot to the approval notification channel:

```text
/invite @JIT Access
```

### Updating the Manifest

When API Gateway URLs change (e.g., stage recreation, resource path changes),
the Slack App manifest must be updated to point to the new endpoints:

1. Run `terraform output -raw jit_access_slack_app_manifest` to get the updated YAML
2. In the Slack App management console, navigate to "App Manifest" and overwrite with the new YAML

Note: The Terraform-generated manifest controls only URL endpoints, slash command
definitions, and OAuth scopes. Other Slack App settings (display name, icons, etc.)
are managed directly in the Slack console.

## Future Enhancements (v2+)

- Multi-account orchestration
- Delegated approval (proxy approvers)
- Audit report generation (S3 + Athena)
