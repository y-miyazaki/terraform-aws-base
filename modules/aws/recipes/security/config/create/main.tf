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
  tags                  = var.tags
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
resource "aws_s3_bucket" "this" {
  count  = var.is_enabled ? 1 : 0
  bucket = lookup(var.aws_s3_bucket, "bucket")
  # bucket_prefix = var.bucket_prefix
  acl           = "private"
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
  count                   = var.is_enabled ? 1 : 0
  bucket                  = aws_s3_bucket.this[0].id
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
  count   = var.is_enabled ? 1 : 0
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
      aws_s3_bucket.this[0].arn
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
      aws_s3_bucket.this[0].arn
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
      "${aws_s3_bucket.this[0].arn}/AWSLogs/${var.account_id}/Config/*"
    ]
  }
  statement {
    sid    = "AWSConfigBucketDelivery2"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig",
        "arn:aws:sts::${var.account_id}:assumed-role/${aws_iam_role.config[0].name}/AWSConfig-BucketConfigCheck",
      ]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.this[0].arn}/AWSLogs/${var.account_id}/Config/*"
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
      aws_s3_bucket.this[0].arn,
      "${aws_s3_bucket.this[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  depends_on = [
    aws_s3_bucket.this,
  ]
}
#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "s3" {
  count  = var.is_enabled ? 1 : 0
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
  s3_bucket_name = aws_s3_bucket.this[0].bucket
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
  tags          = var.tags
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
