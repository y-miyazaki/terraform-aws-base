#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_s3_bucket_common     = merge(var.common_log.aws_s3_bucket_common.aws_s3_bucket, { "bucket" = "${var.name_prefix}${var.common_log.aws_s3_bucket_common.aws_s3_bucket.bucket}-${random_id.this.dec}" })
  aws_s3_bucket_cloudtrail = merge(var.common_log.aws_s3_bucket_cloudtrail.aws_s3_bucket, { "bucket" = "${var.name_prefix}${var.common_log.aws_s3_bucket_cloudtrail.aws_s3_bucket.bucket}-${random_id.this.dec}" })
  config_role_names = var.security_config_us_east_1.is_enabled ? [
    module.aws_recipes_security_config_create_v4.config_role_name,
    # for CloudFront
    module.aws_recipes_security_config_create_v4_us_east_1.config_role_name,
    ] : [
    module.aws_recipes_security_config_create_v4.config_role_name,
  ]
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
# For log
#--------------------------------------------------------------
module "aws_recipes_s3_bucket_log_v4_common" {
  source = "../../modules/aws/recipes/s3/bucket/log-v4"
  tags   = var.tags

  aws_s3_bucket = local.aws_s3_bucket_common
  aws_s3_bucket_acl = lookup(var.common_log.aws_s3_bucket_common, "aws_s3_bucket_acl", {
    acl = "log-delivery-write"
    }
  )
  aws_s3_bucket_versioning = lookup(var.common_log.aws_s3_bucket_common, "aws_s3_bucket_versioning", {
    versioning_configuration = [
      {
        status     = "Enabled"
        mfa_delete = "Disabled"
      }
    ]
    }
  )
  aws_s3_bucket_logging                              = lookup(var.common_log.aws_s3_bucket_common, "aws_s3_bucket_logging", null)
  aws_s3_bucket_lifecycle_configuration              = lookup(var.common_log.aws_s3_bucket_common, "aws_s3_bucket_lifecycle_configuration")
  aws_s3_bucket_server_side_encryption_configuration = lookup(var.common_log.aws_s3_bucket_common, "aws_s3_bucket_server_side_encryption_configuration", null)
  s3_replication_configuration_role_arn              = lookup(var.common_log.aws_s3_bucket_common, "s3_replication_configuration_role_arn", null)
  aws_s3_bucket_replication_configuration            = lookup(var.common_log.aws_s3_bucket_common, "aws_s3_bucket_replication_configuration", null)
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
# Policy for Config etc...
#--------------------------------------------------------------
module "aws_recipes_s3_policy_config_common" {
  source            = "../../modules/aws/recipes/s3/policy/config"
  bucket            = module.aws_recipes_s3_bucket_log_v4_common.id
  bucket_arn        = module.aws_recipes_s3_bucket_log_v4_common.arn
  account_id        = data.aws_caller_identity.current.account_id
  config_role_names = local.config_role_names
  depends_on = [
    module.aws_recipes_s3_bucket_log_v4_common
  ]
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
# For CloudTrail
#--------------------------------------------------------------
module "aws_recipes_s3_bucket_log_v4_cloudtrail" {
  source = "../../modules/aws/recipes/s3/bucket/log-v4"
  tags   = var.tags

  aws_s3_bucket = local.aws_s3_bucket_cloudtrail
  aws_s3_bucket_acl = lookup(var.common_log.aws_s3_bucket_cloudtrail, "aws_s3_bucket_acl", {
    acl = "log-delivery-write"
    }
  )
  aws_s3_bucket_versioning = lookup(var.common_log.aws_s3_bucket_cloudtrail, "aws_s3_bucket_versioning", {
    versioning_configuration = [
      {
        status     = "Enabled"
        mfa_delete = "Disabled"
      }
    ]
    }
  )
  aws_s3_bucket_logging                              = lookup(var.common_log.aws_s3_bucket_cloudtrail, "aws_s3_bucket_logging", null)
  aws_s3_bucket_lifecycle_configuration              = lookup(var.common_log.aws_s3_bucket_cloudtrail, "aws_s3_bucket_lifecycle_configuration")
  aws_s3_bucket_server_side_encryption_configuration = lookup(var.common_log.aws_s3_bucket_cloudtrail, "aws_s3_bucket_server_side_encryption_configuration", null)
  s3_replication_configuration_role_arn              = lookup(var.common_log.aws_s3_bucket_cloudtrail, "s3_replication_configuration_role_arn", null)
  aws_s3_bucket_replication_configuration            = lookup(var.common_log.aws_s3_bucket_cloudtrail, "aws_s3_bucket_replication_configuration", null)

  depends_on = [
    module.aws_recipes_s3_bucket_log_v4_common,
  ]
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
# Policy for CloudTrail.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_cloudtrail_cloudtrail" {
  source     = "../../modules/aws/recipes/s3/policy/cloudtrail"
  bucket     = module.aws_recipes_s3_bucket_log_v4_cloudtrail.id
  bucket_arn = module.aws_recipes_s3_bucket_log_v4_cloudtrail.arn
  account_id = data.aws_caller_identity.current.account_id
  depends_on = [
    module.aws_recipes_s3_bucket_log_v4_common,
    module.aws_recipes_s3_bucket_log_v4_cloudtrail
  ]
}
