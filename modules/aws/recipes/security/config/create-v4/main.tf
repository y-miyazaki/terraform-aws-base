#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  is_s3_enabled = var.is_enabled && var.is_s3_enabled
  bucket_id     = local.is_s3_enabled ? aws_s3_bucket.this[0].id : var.aws_s3_bucket_existing.bucket_id
  bucket_arn    = local.is_s3_enabled ? aws_s3_bucket.this[0].arn : var.aws_s3_bucket_existing.bucket_arn
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "config" {
  count                 = var.is_enabled ? 1 : 0
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
  tags                  = local.tags
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "config" {
  count      = var.is_enabled ? 1 : 0
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}
#--------------------------------------------------------------
# Provides an AWS Config Configuration Recorder. Please note that this resource does not start the created recorder automatically.
#--------------------------------------------------------------
resource "aws_config_configuration_recorder" "this" {
  count    = var.is_enabled ? 1 : 0
  name     = lookup(var.aws_config_configuration_recorder, "name")
  role_arn = aws_iam_role.config[0].arn
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
#tfsec:ignore:AWS002 tfsec:ignore:AWS017 tfsec:ignore:AWS077 tfsec:ignore:AWS098
resource "aws_s3_bucket" "this" {
  count  = local.is_s3_enabled ? 1 : 0
  bucket = lookup(var.aws_s3_bucket, "bucket")
  # bucket_prefix = var.bucket_prefix
  tags          = local.tags
  force_destroy = lookup(var.aws_s3_bucket, "force_destroy", false)
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
# Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will suspend versioning on the associated S3 bucket. For more information, see How S3 versioning works.
#--------------------------------------------------------------
resource "aws_s3_bucket_acl" "this" {
  count = local.is_s3_enabled && var.aws_s3_bucket_acl != null ? 1 : 0
  acl   = lookup(var.aws_s3_bucket_acl, "acl")
  dynamic "access_control_policy" {
    for_each = lookup(var.aws_s3_bucket_acl, "access_control_policy", [])
    content {
      dynamic "grant" {
        for_each = lookup(access_control_policy.value, "grant", [])
        content {
          dynamic "grantee" {
            for_each = lookup(grant.value, "grantee", [])
            content {
              email_address = lookup(grantee.value, "email_address", null)
              id            = lookup(grantee.value, "id", null)
              type          = lookup(grantee.value, "type", null)
              uri           = lookup(grantee.value, "uri", null)
            }
          }
          permission = lookup(grant.value, "permission", null)
        }
      }
      dynamic "owner" {
        for_each = lookup(access_control_policy.value, "owner", [])
        content {
          id           = lookup(owner.value, "id", null)
          display_name = lookup(owner.value, "display_name", null)
        }
      }
    }
  }
  bucket                = aws_s3_bucket.this[0].id
  expected_bucket_owner = lookup(var.aws_s3_bucket_acl, "expected_bucket_owner", null)

}

#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  count  = local.is_s3_enabled && var.aws_s3_bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  policy = lookup(var.aws_s3_bucket_policy, "policy")
}

#--------------------------------------------------------------
# Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will suspend versioning on the associated S3 bucket. For more information, see How S3 versioning works.
#--------------------------------------------------------------
resource "aws_s3_bucket_versioning" "this" {
  count  = local.is_s3_enabled && var.aws_s3_bucket_versioning != null ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  dynamic "versioning_configuration" {
    for_each = lookup(var.aws_s3_bucket_versioning, "versioning_configuration", [])
    content {
      status     = lookup(versioning_configuration.value, "status", null)
      mfa_delete = lookup(versioning_configuration.value, "mfa_delete", null)
    }
  }
}

#--------------------------------------------------------------
# Provides a S3 bucket server-side encryption configuration resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = local.is_s3_enabled && var.aws_s3_bucket_server_side_encryption_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this[0].bucket

  dynamic "rule" {
    for_each = lookup(var.aws_s3_bucket_server_side_encryption_configuration, "rule", [])
    content {
      dynamic "apply_server_side_encryption_by_default" {
        for_each = lookup(rule.value, "apply_server_side_encryption_by_default", [])
        content {
          sse_algorithm     = lookup(apply_server_side_encryption_by_default.value, "sse_algorithm", null)
          kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
        }
      }
      bucket_key_enabled = lookup(rule.value, "bucket_key_enabled", null)
    }
  }
}

#--------------------------------------------------------------
# Provides a S3 bucket logging resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_logging" "this" {
  count                 = local.is_s3_enabled && var.aws_s3_bucket_logging != null ? 1 : 0
  bucket                = aws_s3_bucket.this[0].bucket
  expected_bucket_owner = lookup(var.aws_s3_bucket_logging, "expected_bucket_owner", null)
  target_bucket         = lookup(var.aws_s3_bucket_logging, "target_bucket", null)
  target_prefix         = lookup(var.aws_s3_bucket_logging, "target_prefix", null)
  dynamic "target_grant" {
    for_each = lookup(var.aws_s3_bucket_logging, "target_grant", [])
    content {
      dynamic "grantee" {
        for_each = lookup(target_grant.value, "grantee", [])
        content {
          email_address = lookup(grantee.value, "email_address", null)
          id            = lookup(grantee.value, "id", null)
          type          = lookup(grantee.value, "type", null)
          uri           = lookup(grantee.value, "uri", null)
        }
      }
      permission = lookup(target_grant.value, "permission", null)
    }
  }
}
#--------------------------------------------------------------
# Provides an independent configuration resource for S3 bucket lifecycle configuration.
#--------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count                 = local.is_s3_enabled && var.aws_s3_bucket_lifecycle_configuration != null ? 1 : 0
  bucket                = aws_s3_bucket.this[0].bucket
  expected_bucket_owner = lookup(var.aws_s3_bucket_lifecycle_configuration, "expected_bucket_owner", null)
  dynamic "rule" {
    for_each = lookup(var.aws_s3_bucket_lifecycle_configuration, "rule", [])
    content {
      dynamic "abort_incomplete_multipart_upload" {
        for_each = lookup(rule.value, "abort_incomplete_multipart_upload", [])
        content {
          days_after_initiation = lookup(abort_incomplete_multipart_upload.value, "days_after_initiation", null)
        }
      }
      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration", [])
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }
      dynamic "filter" {
        for_each = lookup(rule.value, "filter", [])
        content {
          dynamic "and" {
            for_each = lookup(filter.value, "and", [])
            content {
              object_size_greater_than = lookup(and.value, "object_size_greater_than", null)
              object_size_less_than    = lookup(and.value, "object_size_less_than", null)
              prefix                   = lookup(and.value, "prefix", null)
              tags                     = lookup(and.value, "tags", null)
            }
          }
          object_size_greater_than = lookup(filter.value, "object_size_greater_than", null)
          object_size_less_than    = lookup(filter.value, "object_size_less_than", null)
          prefix                   = lookup(filter.value, "prefix", null)
          dynamic "tag" {
            for_each = lookup(filter.value, "tag", [])
            content {
              key   = lookup(tag.value, "key", null)
              value = lookup(tag.value, "value", null)
            }
          }
        }
      }
      id = lookup(rule.value, "id")
      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration", [])
        content {
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions", null)
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
        }
      }
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])
        content {
          newer_noncurrent_versions = lookup(noncurrent_version_transition.value, "newer_noncurrent_versions", null)
          noncurrent_days           = lookup(noncurrent_version_transition.value, "noncurrent_days", null)
          storage_class             = lookup(noncurrent_version_transition.value, "storage_class", null)
        }
      }
      prefix = lookup(rule.value, "prefix", null)
      status = lookup(rule.value, "status", null)
      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = lookup(transition.value, "storage_class", null)
        }
      }
    }
  }
}

#--------------------------------------------------------------
# Provides an independent configuration resource for S3 bucket replication configuration.
#--------------------------------------------------------------
resource "aws_s3_bucket_replication_configuration" "this" {
  count  = local.is_s3_enabled && var.aws_s3_bucket_replication_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  role   = var.s3_replication_configuration_role_arn

  dynamic "rule" {
    for_each = lookup(var.aws_s3_bucket_replication_configuration, "rule", [])
    content {
      dynamic "delete_marker_replication" {
        for_each = lookup(rule.value, "delete_marker_replication", [])
        content {
          status = lookup(delete_marker_replication.value, "status", null)
        }
      }
      dynamic "destination" {
        for_each = lookup(rule.value, "destination", [])
        content {
          dynamic "access_control_translation" {
            for_each = lookup(destination.value, "access_control_translation", [])
            content {
              owner = lookup(access_control_translation.value, "owner", null)
            }
          }
          account = lookup(destination.value, "account", null)
          bucket  = lookup(destination.value, "bucket", null)
          dynamic "encryption_configuration" {
            for_each = lookup(destination.value, "encryption_configuration", [])
            content {
              replica_kms_key_id = lookup(encryption_configuration.value, "replica_kms_key_id", null)
            }
          }
          dynamic "metrics" {
            for_each = lookup(destination.value, "metrics", [])
            content {
              dynamic "event_threshold" {
                for_each = lookup(metrics.value, "event_threshold", [])
                content {
                  minutes = lookup(event_threshold.value, "minutes", null)
                }
              }
              status = lookup(metrics.value, "status", null)
            }
          }

          dynamic "replication_time" {
            for_each = lookup(destination.value, "replication_time", [])
            content {
              status = lookup(replication_time.value, "status", null)
              dynamic "time" {
                for_each = lookup(replication_time.value, "time", [])
                content {
                  minutes = lookup(time.value, "minutes", null)
                }
              }
            }
          }
          storage_class = lookup(destination.value, "storage_class", null)
        }
      }
      dynamic "existing_object_replication" {
        for_each = lookup(rule.value, "existing_object_replication", [])
        content {
          status = lookup(existing_object_replication.value, "status", null)
        }
      }
      dynamic "filter" {
        for_each = lookup(rule.value, "filter", [])
        content {
          dynamic "and" {
            for_each = lookup(filter.value, "and", [])
            content {
              prefix = lookup(and.value, "prefix", null)
              tags   = lookup(and.value, "tags", null)
            }
          }
          prefix = lookup(filter.value, "prefix", null)
          dynamic "tag" {
            for_each = lookup(filter.value, "tag", [])
            content {
              key   = lookup(tag.value, "key", null)
              value = lookup(tag.value, "value", null)
            }
          }
        }
      }
      id       = lookup(rule.value, "id", null)
      prefix   = lookup(rule.value, "prefix", null)
      priority = lookup(rule.value, "priority", null)
      dynamic "source_selection_criteria" {
        for_each = lookup(rule.value, "source_selection_criteria", [])
        content {
          dynamic "replica_modifications" {
            for_each = lookup(source_selection_criteria.value, "replica_modifications", null)
            content {
              status = lookup(replica_modifications.value, "status", null)
            }
          }
          dynamic "sse_kms_encrypted_objects" {
            for_each = lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", null)
            content {
              status = lookup(sse_kms_encrypted_objects.value, "status", null)
            }
          }
        }
      }
      status = lookup(rule.value, "status", null)
    }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}

#--------------------------------------------------------------
# Manages S3 bucket-level Public Access Block configuration. For more information about these settings, see the AWS S3 Block Public Access documentation.
#--------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "this" {
  count                   = local.is_s3_enabled ? 1 : 0
  bucket                  = local.bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [
    aws_s3_bucket.this
  ]
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "s3" {
  count   = local.is_s3_enabled ? 1 : 0
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
      local.bucket_arn
    ]
  }
  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      local.bucket_arn
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
      "${local.bucket_arn}/AWSLogs/${var.account_id}/Config/*"
    ]
  }
  statement {
    sid    = "AWSConfigBucketDelivery2"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:assumed-role/${aws_iam_role.config[0].name}/AWSConfig-BucketConfigCheck",
        "arn:aws:sts::${var.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig",
      ]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${local.bucket_arn}/AWSLogs/${var.account_id}/Config/*"
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
      local.bucket_arn,
      "${local.bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  depends_on = [
    aws_iam_role.config,
    aws_s3_bucket.this,
  ]
}
#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "s3" {
  count  = local.is_s3_enabled ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  policy = data.aws_iam_policy_document.s3[0].json
  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_public_access_block.this
  ]
}

#--------------------------------------------------------------
# Provides an AWS Config Delivery Channel.
#--------------------------------------------------------------
resource "aws_config_delivery_channel" "this" {
  count          = var.is_enabled ? 1 : 0
  name           = lookup(var.aws_config_delivery_channel, "name")
  s3_bucket_name = local.bucket_id
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
  count      = var.is_enabled ? 1 : 0
  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = lookup(var.aws_config_configuration_recorder_status, "is_enabled", true)
  depends_on = [
    aws_config_delivery_channel.this,
    aws_config_configuration_recorder.this
  ]
}

#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count = var.is_enabled ? 1 : 0
  name  = lookup(var.aws_cloudwatch_event_rule, "name")
  # event_pattern: https://aws.amazon.com/jp/premiumsupport/knowledge-center/config-resource-non-compliant/
  event_pattern = <<EVENT_PATTERN
{
    "source": [
        "aws.config"
    ],
    "detail-type": [
        "Config Rules Compliance Change"
    ],
    "detail": {
        "messageType": [
            "ComplianceChangeNotification"
        ],
        "newEvaluationResult": {
            "complianceType": [
                "NON_COMPLIANT"
            ]
        }
    }
}
EVENT_PATTERN
  description   = lookup(var.aws_cloudwatch_event_rule, "description")
  is_enabled    = true
  tags          = local.tags
}
#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.this[0].name
  arn   = lookup(var.aws_cloudwatch_event_target, "arn")
  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
