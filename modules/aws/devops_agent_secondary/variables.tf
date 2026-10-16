#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) Whether to create the secondary account role."
  default     = true
}

variable "account_id" {
  type        = string
  description = "(Required) AWS account ID of this (secondary) account."
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "primary" {
  type = object({
    # (Required) AWS account ID that hosts the Agent Space.
    account_id = string
    # (Required) ARN of the Agent Space allowed to assume the role (no wildcard).
    agent_space_arn = string
  })
  description = "(Required) Primary account and the Agent Space that is trusted."
  validation {
    condition     = can(regex("^[0-9]{12}$", var.primary.account_id))
    error_message = "primary.account_id must be a 12-digit AWS account ID."
  }
  validation {
    condition     = can(regex("^arn:aws:aidevops:[a-z0-9-]+:[0-9]{12}:agentspace/[A-Za-z0-9-]+$", var.primary.agent_space_arn))
    error_message = "primary.agent_space_arn must be an Agent Space ARN (arn:aws:aidevops:<region>:<account>:agentspace/<id>) without wildcards."
  }
}

variable "aws_iam_role" {
  type = object({
    # (Optional) Description of the IAM role.
    description = optional(string, "Cross-account role assumed by AWS DevOps Agent in the primary account to investigate this account.")
    # (Required) Name of the IAM role. The primary account derives the role ARN from this name.
    name = string
    # (Optional) Path of the IAM role.
    path = optional(string, "/")
  })
  description = "(Required) IAM role configuration."
}

variable "default_policy_statements" {
  type = list(object({
    # (Required) IAM actions, e.g. ["s3:GetBucketVersioning"].
    actions = list(string)
    # (Optional) Allow or Deny.
    effect = optional(string, "Allow")
    # (Required) Resource ARNs the statement applies to.
    resources = list(string)
    # (Required) Statement ID (alphanumeric, unique within the list).
    sid = string
  }))
  description = "(Optional) Baseline read-only statements attached to the role on top of AIDevOpsAgentAccessPolicy, for metadata reads the managed policy lacks (AccessDenied in the investigation). Only add actions that return no secrets or credentials; never allow secretsmanager:GetSecretValue or apigateway API key reads. Set [] to attach none. additional_policy_statements is merged after this list."
  default = [
    {
      sid = "AllowReadMetadata"
      actions = [
        "cloudformation:ListStacks",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "ecs:ListClusters",
        "eks:ListClusters",
        "kms:GetKeyRotationStatus",
        "kms:ListResourceTags",
        "lambda:ListFunctions",
        "rds:DescribeEvents",
        "redshift:GetResourcePolicy",
      ]
      resources = ["*"]
    },
    {
      sid       = "AllowReadGlueTriggers"
      actions   = ["glue:GetTrigger", "glue:GetTriggers"]
      resources = ["*"]
    },
    {
      sid = "AllowReadS3BucketConfiguration"
      actions = [
        "s3:GetAccelerateConfiguration",
        "s3:GetAnalyticsConfiguration",
        "s3:GetBucketCORS",
        "s3:GetBucketLogging",
        "s3:GetBucketNotification",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketOwnershipControls",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetBucketTagging",
        "s3:GetBucketVersioning",
        "s3:GetBucketWebsite",
        "s3:GetEncryptionConfiguration",
        "s3:GetIntelligentTieringConfiguration",
        "s3:GetInventoryConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:GetMetricsConfiguration",
        "s3:GetReplicationConfiguration",
      ]
      resources = ["arn:aws:s3:::*"]
    },
    {
      sid       = "AllowReadApiGatewayVpcLinks"
      actions   = ["apigateway:GET"]
      resources = ["arn:aws:apigateway:*::/vpclinks", "arn:aws:apigateway:*::/vpclinks/*"]
    },
  ]
  validation {
    condition     = alltrue([for s in var.default_policy_statements : contains(["Allow", "Deny"], s.effect)])
    error_message = "default_policy_statements[*].effect must be Allow or Deny."
  }
  validation {
    condition     = alltrue([for s in var.default_policy_statements : can(regex("^[A-Za-z0-9]+$", s.sid))])
    error_message = "default_policy_statements[*].sid must be alphanumeric."
  }
}

variable "additional_policy_statements" {
  type = list(object({
    # (Required) IAM actions, e.g. ["lambda:GetFunction"].
    actions = list(string)
    # (Optional) Allow or Deny.
    effect = optional(string, "Allow")
    # (Required) Resource ARNs the statement applies to.
    resources = list(string)
    # (Required) Statement ID (alphanumeric, unique within the list).
    sid = string
  }))
  description = "(Optional) Extra IAM policy statements attached to the role on top of AIDevOpsAgentAccessPolicy (e.g. read actions the managed policy lacks). Keep them least privilege."
  default     = []
  validation {
    condition     = alltrue([for s in var.additional_policy_statements : contains(["Allow", "Deny"], s.effect)])
    error_message = "additional_policy_statements[*].effect must be Allow or Deny."
  }
  validation {
    condition     = alltrue([for s in var.additional_policy_statements : can(regex("^[A-Za-z0-9]+$", s.sid))])
    error_message = "additional_policy_statements[*].sid must be alphanumeric."
  }
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources."
  default     = {}
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Accepted for a uniform module interface; this module manages only global resources (IAM), so the value is not used."
  default     = null
}
