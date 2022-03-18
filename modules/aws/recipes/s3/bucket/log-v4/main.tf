#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  name = var.is_random_name_suffix ? "${var.aws_s3_bucket.bucket}-${random_id.this.dec}" : var.aws_s3_bucket.bucket
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# create random id for s3 bukect name
#--------------------------------------------------------------
resource "random_id" "this" {
  byte_length = 4
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
#--------------------------------------------------------------
#tfsec:ignore:AWS002 tfsec:ignore:AWS017 tfsec:ignore:AWS077
resource "aws_s3_bucket" "this" {
  bucket        = local.name
  force_destroy = lookup(var.aws_s3_bucket, "force_destroy", null)

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
  tags = local.tags
}
#--------------------------------------------------------------
# Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will suspend versioning on the associated S3 bucket. For more information, see How S3 versioning works.
#--------------------------------------------------------------
resource "aws_s3_bucket_acl" "this" {
  count = var.aws_s3_bucket_acl == null ? 0 : 1
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
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = lookup(var.aws_s3_bucket_acl, "expected_bucket_owner", null)

}

#--------------------------------------------------------------
# Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will suspend versioning on the associated S3 bucket. For more information, see How S3 versioning works.
#--------------------------------------------------------------
resource "aws_s3_bucket_versioning" "this" {
  count  = var.aws_s3_bucket_versioning == null ? 0 : 1
  bucket = aws_s3_bucket.this.id
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
  count  = var.aws_s3_bucket_server_side_encryption_configuration == null ? 0 : 1
  bucket = aws_s3_bucket.this.bucket

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
  count                 = var.aws_s3_bucket_logging == null ? 0 : 1
  bucket                = aws_s3_bucket.this.bucket
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
  count                 = var.aws_s3_bucket_lifecycle_configuration == null ? 0 : 1
  bucket                = aws_s3_bucket.this.bucket
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
  count  = var.aws_s3_bucket_replication_configuration == null ? 0 : 1
  bucket = aws_s3_bucket.this.id
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
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
