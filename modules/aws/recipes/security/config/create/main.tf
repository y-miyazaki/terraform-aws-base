#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "config" {
  description           = lookup(var.aws_iam_role, "description", null)
  name                  = lookup(var.aws_iam_role, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  path                  = lookup(var.aws_iam_role, "path", "/")
  force_detach_policies = true
  tags                  = var.tags
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "config" {
  statement {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate",
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeLifecycleHooks",
      "autoscaling:DescribePolicies",
      "autoscaling:DescribeScheduledActions",
      "autoscaling:DescribeTags",
      "backup:ListBackupPlans",
      "backup:ListBackupSelections",
      "backup:GetBackupSelection",
      "cloudfront:ListTagsForResource",
      "cloudformation:DescribeType",
      "cloudformation:ListTypes",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetEventSelectors",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:ListTags",
      "cloudwatch:DescribeAlarms",
      "codepipeline:GetPipeline",
      "codepipeline:GetPipelineState",
      "codepipeline:ListPipelines",
      "config:BatchGet*",
      "config:Describe*",
      "config:Get*",
      "config:List*",
      "config:Put*",
      "config:Select*",
      "dax:DescribeClusters",
      "dms:DescribeReplicationInstances",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTable",
      "dynamodb:ListTables",
      "dynamodb:ListTagsOfResource",
      "ec2:Describe*",
      "ec2:GetEbsEncryptionByDefault",
      "ecr:DescribeRepositories",
      "ecr:GetLifecyclePolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:ListTagsForResource",
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTaskSets",
      "ecs:ListClusters",
      "ecs:ListServices",
      "ecs:ListTagsForResource",
      "ecs:ListTaskDefinitions",
      "eks:DescribeCluster",
      "eks:DescribeNodegroup",
      "eks:ListClusters",
      "eks:ListNodegroups",
      "elasticache:DescribeCacheClusters",
      "elasticache:DescribeReplicationGroups",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeLifecycleConfiguration",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:DescribeMountTargetSecurityGroups",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancerPolicies",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTags",
      "elasticmapreduce:DescribeCluster",
      "elasticmapreduce:DescribeSecurityConfiguration",
      "elasticmapreduce:GetBlockPublicAccessConfiguration",
      "elasticmapreduce:ListClusters",
      "elasticmapreduce:ListInstances",
      "es:DescribeElasticsearchDomain",
      "es:DescribeElasticsearchDomains",
      "es:ListDomainNames",
      "es:ListTags",
      "guardduty:GetDetector",
      "guardduty:GetFindings",
      "guardduty:GetMasterAccount",
      "guardduty:ListDetectors",
      "guardduty:ListFindings",
      "iam:GenerateCredentialReport",
      "iam:GetAccountAuthorizationDetails",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:GetCredentialReport",
      "iam:GetGroup",
      "iam:GetGroupPolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetUser",
      "iam:GetUserPolicy",
      "iam:ListAttachedGroupPolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListAttachedUserPolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListGroupPolicies",
      "iam:ListGroupsForUser",
      "iam:ListInstanceProfilesForRole",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:ListUserPolicies",
      "iam:ListVirtualMFADevices",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListKeys",
      "kms:ListResourceTags",
      "lambda:GetAlias",
      "lambda:GetFunction",
      "lambda:GetPolicy",
      "lambda:ListAliases",
      "lambda:ListFunctions",
      "logs:DescribeLogGroups",
      "organizations:DescribeOrganization",
      "rds:DescribeDBClusters",
      "rds:DescribeDBClusterSnapshotAttributes",
      "rds:DescribeDBClusterSnapshots",
      "rds:DescribeDBInstances",
      "rds:DescribeDBSecurityGroups",
      "rds:DescribeDBSnapshotAttributes",
      "rds:DescribeDBSnapshots",
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeEventSubscriptions",
      "rds:ListTagsForResource",
      "redshift:DescribeClusterParameterGroups",
      "redshift:DescribeClusterParameters",
      "redshift:DescribeClusterSecurityGroups",
      "redshift:DescribeClusterSnapshots",
      "redshift:DescribeClusterSubnetGroups",
      "redshift:DescribeClusters",
      "redshift:DescribeEventSubscriptions",
      "redshift:DescribeLoggingStatus",
      "s3:GetAccelerateConfiguration",
      "s3:GetAccountPublicAccessBlock",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DescribeNotebookInstance",
      "sagemaker:ListEndpointConfigs",
      "sagemaker:ListNotebookInstances",
      "secretsmanager:ListSecrets",
      "secretsmanager:ListSecretVersionIds",
      "securityhub:describeHub",
      "shield:DescribeDRTAccess",
      "shield:DescribeProtection",
      "shield:DescribeSubscription",
      "sns:GetTopicAttributes",
      "sns:ListSubscriptions",
      "sns:ListTagsForResource",
      "sns:ListTopics",
      "sqs:GetQueueAttributes",
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "ssm:DescribeAutomationExecutions",
      "ssm:DescribeDocument",
      "ssm:GetAutomationExecution",
      "ssm:GetDocument",
      "storagegateway:ListGateways",
      "storagegateway:ListVolumes",
      "support:DescribeCases",
      "tag:GetResources",
      "waf:GetLoggingConfiguration",
      "waf:GetWebACL",
      "wafv2:GetLoggingConfiguration",
      "waf-regional:GetLoggingConfiguration",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource"
    ]
    resources = ["*"]
  }
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "config" {
  description = lookup(var.aws_iam_policy, "description", null)
  name        = lookup(var.aws_iam_policy, "name")
  path        = lookup(var.aws_iam_policy, "path", "/")
  policy      = data.aws_iam_policy_document.config.json
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = aws_iam_policy.config.arn
}
#--------------------------------------------------------------
# Provides an AWS Config Configuration Recorder. Please note that this resource does not start the created recorder automatically.
#--------------------------------------------------------------
resource "aws_config_configuration_recorder" "this" {
  name     = lookup(var.aws_config_configuration_recorder, "name", null)
  role_arn = aws_iam_role.config.arn
  dynamic "recording_group" {
    for_each = lookup(var.aws_config_configuration_recorder, "recording_group", [])
    content {
      all_supported                 = lookup(recording_group.value, "all_supported", null)
      include_global_resource_types = lookup(recording_group.value, "include_global_resource_types", null)
      resource_types                = lookup(recording_group.value, "resource_types", null)
    }
  }
  depends_on = [
    aws_iam_role.config
  ]
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  bucket = lookup(var.aws_s3_bucket, "bucket")
  # bucket_prefix = var.bucket_prefix
  acl           = lookup(var.aws_s3_bucket, "acl", "private")
  tags          = var.tags
  force_destroy = lookup(var.aws_s3_bucket, "force_destroy", false)
  dynamic "versioning" {
    for_each = lookup(var.aws_s3_bucket, "versioning", [])
    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }
  dynamic "logging" {
    for_each = lookup(var.aws_s3_bucket, "logging", [])
    content {
      target_bucket = lookup(logging.value, "target_bucket", null)
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }
  # see lifecycle document.
  # https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/lifecycle-transition-general-considerations.html
  dynamic "lifecycle_rule" {
    for_each = lookup(var.aws_s3_bucket, "lifecycle_rule", [])
    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      enabled                                = lookup(lifecycle_rule.value, "enabled", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      dynamic "expiration" {
        for_each = lookup(lifecycle_rule.value, "expiration", [])
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = lookup(transition.value, "storage_class", null)
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_expiration", [])
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])
        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = lookup(noncurrent_version_transition.value, "storage_class", null)
        }
      }
    }
  }
  dynamic "replication_configuration" {
    for_each = lookup(var.aws_s3_bucket, "replication_configuration", [])
    content {
      role = lookup(replication_configuration.value, "role", null)
      dynamic "rules" {
        for_each = lookup(replication_configuration.value, "rules", [])
        content {
          id       = lookup(rules.value, "id", null)
          priority = lookup(rules.value, "priority", null)
          dynamic "destination" {
            for_each = lookup(rules.value, "destination", [])
            content {
              bucket             = lookup(destination.value, "bucket", null)
              storage_class      = lookup(destination.value, "storage_class", null)
              replica_kms_key_id = lookup(destination.value, "replica_kms_key_id", null)
              dynamic "access_control_translation" {
                for_each = lookup(destination.value, "access_control_translation", [])
                content {
                  owner = lookup(access_control_translation.value, "owner", null)
                }
              }
              account_id = lookup(destination.value, "account_id", null)
            }
          }
          dynamic "source_selection_criteria" {
            for_each = lookup(rules.value, "source_selection_criteria", [])
            content {
              dynamic "sse_kms_encrypted_objects" {
                for_each = lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", [])
                content {
                  enabled = lookup(sse_kms_encrypted_objects.value, "enabled", null)
                }
              }
            }
          }
          prefix = lookup(rules.value, "prefix", null)
          status = lookup(rules.value, "status", null)
          dynamic "filter" {
            for_each = lookup(rules.value, "filter", [])
            content {
              prefix = lookup(filter.value, "prefix", null)
              tags   = lookup(filter.value, "tags", null)
            }
          }
        }
      }
    }
  }
  dynamic "server_side_encryption_configuration" {
    for_each = lookup(var.aws_s3_bucket, "server_side_encryption_configuration", [])
    content {
      dynamic "rule" {
        for_each = lookup(server_side_encryption_configuration.value, "rule", [])
        content {
          dynamic "apply_server_side_encryption_by_default" {
            for_each = lookup(rule.value, "apply_server_side_encryption_by_default", [])
            content {
              sse_algorithm     = lookup(apply_server_side_encryption_by_default.value, "sse_algorithm", null)
              kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
            }
          }
        }
      }
    }
  }
  dynamic "object_lock_configuration" {
    for_each = lookup(var.aws_s3_bucket, "object_lock_configuration", [])
    content {
      object_lock_enabled = lookup(object_lock_configuration.value, "object_lock_enabled", null)
      dynamic "rule" {
        for_each = lookup(object_lock_configuration.value, "rule", [])
        content {
          dynamic "default_retention" {
            for_each = lookup(rule.value, "default_retention", [])
            content {
              mode  = lookup(default_retention.value, "mode", null)
              days  = lookup(default_retention.value, "days", null)
              years = lookup(default_retention.value, "years", null)
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------
# Manages S3 bucket-level Public Access Block configuration. For more information about these settings, see the AWS S3 Block Public Access documentation.
#--------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "s3" {
  version = "2012-10-17"
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      aws_s3_bucket.this.arn
    ]
  }
  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/AWSLogs/${var.account_id}/Config/*"
    ]
  }
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "s3" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3.json
}

#--------------------------------------------------------------
# Provides an AWS Config Delivery Channel.
#--------------------------------------------------------------
resource "aws_config_delivery_channel" "this" {
  name           = lookup(var.aws_config_delivery_channel, "name")
  s3_bucket_name = aws_s3_bucket.this.bucket
  sns_topic_arn  = lookup(var.aws_config_delivery_channel, "sns_topic_arn", null)
  dynamic "snapshot_delivery_properties" {
    for_each = lookup(var.aws_config_delivery_channel, "snapshot_delivery_properties", [])
    content {
      delivery_frequency = lookup(snapshot_delivery_properties.value, "delivery_frequency", null)
    }
  }
  depends_on = [
    aws_s3_bucket.this,
    aws_config_configuration_recorder.this
  ]
}

#--------------------------------------------------------------
# Manages status (recording / stopped) of an AWS Config Configuration Recorder.
#--------------------------------------------------------------
resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = lookup(var.aws_config_configuration_recorder_status, "is_enabled", true)
  depends_on = [
    aws_config_delivery_channel.this,
    aws_config_configuration_recorder.this
  ]
}
