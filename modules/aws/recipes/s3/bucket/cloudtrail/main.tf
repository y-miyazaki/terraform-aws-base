#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  name = var.is_random_name_suffix ? "${var.bucket}-${random_id.this.dec}" : var.bucket
}
#--------------------------------------------------------------
# create random id for s3 bukect name
#--------------------------------------------------------------
resource "random_id" "this" {
  byte_length = 4
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  bucket = local.name
  # bucket_prefix = var.bucket_prefix
  acl  = var.acl
  tags = var.tags

  force_destroy = var.force_destroy
  # dynamic "website" {
  #   for_each = var.website
  #   content {
  #     index_document           = lookup(website.value, "index_document", null)
  #     error_document           = lookup(website.value, "error_document", null)
  #     redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
  #     routing_rules            = lookup(website.value, "routing_rules", null)
  #   }
  # }
  # dynamic "cors_rule" {
  #   for_each = var.cors_rule
  #   content {
  #     allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
  #     allowed_methods = lookup(cors_rule.value, "allowed_methods", null)
  #     allowed_origins = lookup(cors_rule.value, "allowed_origins", null)
  #     expose_headers  = lookup(cors_rule.value, "expose_headers", null)
  #     max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
  #   }
  # }
  #tfsec:ignore:AWS077
  dynamic "versioning" {
    for_each = var.versioning
    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }
  #tfsec:ignore:AWS002
  dynamic "logging" {
    for_each = var.logging
    content {
      target_bucket = lookup(logging.value, "target_bucket", null)
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }
  # see lifecycle document.
  # https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/lifecycle-transition-general-considerations.html
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule
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
  acceleration_status = var.acceleration_status
  #   region              = var.region
  request_payer = var.request_payer
  dynamic "replication_configuration" {
    for_each = var.replication_configuration
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
  dynamic "server_side_encryption_configuration" { #tfsec:ignore:AWS017
    for_each = var.server_side_encryption_configuration
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
    for_each = var.object_lock_configuration
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
# Provides IAM Policy document.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      aws_s3_bucket.this.arn
    ]
  }
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/AWSLogs/${var.account_id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
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
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}
