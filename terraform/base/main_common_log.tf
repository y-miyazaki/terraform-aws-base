#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_s3_bucket_common     = merge(var.common_log.aws_s3_bucket_common, { "bucket" = "${var.name_prefix}${var.common_log.aws_s3_bucket_common.bucket}-${random_id.this.dec}" })
  aws_s3_bucket_cloudtrail = merge(var.common_log.aws_s3_bucket_cloudtrail, { "bucket" = "${var.name_prefix}${var.common_log.aws_s3_bucket_cloudtrail.bucket}-${random_id.this.dec}" })
  config_role_names = var.security_config_us_east_1.is_enabled ? [
    module.aws_recipes_security_config_create.config_role_name,
    # for CloudFront
    module.aws_recipes_security_config_create_us_east_1.config_role_name,
    ] : [
    module.aws_recipes_security_config_create.config_role_name,
  ]
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
# For log
#--------------------------------------------------------------
module "aws_recipes_s3_bucket_log_common" {
  source        = "../../modules/aws/recipes/s3/bucket/log"
  bucket        = lookup(local.aws_s3_bucket_common, "bucket")
  acl           = lookup(local.aws_s3_bucket_common, "acl", "log-delivery-write")
  tags          = var.tags
  force_destroy = lookup(local.aws_s3_bucket_common, "force_destroy", false)
  versioning = lookup(local.aws_s3_bucket_common, "versioning", [
    {
      enabled = true
    }
    ]
  )
  logging                              = lookup(local.aws_s3_bucket_common, "logging", [])
  lifecycle_rule                       = lookup(local.aws_s3_bucket_common, "lifecycle_rule", [])
  replication_configuration            = lookup(local.aws_s3_bucket_common, "replication_configuration", [])
  server_side_encryption_configuration = lookup(local.aws_s3_bucket_common, "server_side_encryption_configuration", [])
  object_lock_configuration            = lookup(local.aws_s3_bucket_common, "object_lock_configuration", [])
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
# Policy for Config etc...
#--------------------------------------------------------------
module "aws_recipes_s3_policy_config_common" {
  source            = "../../modules/aws/recipes/s3/policy/config"
  bucket            = module.aws_recipes_s3_bucket_log_common.id
  bucket_arn        = module.aws_recipes_s3_bucket_log_common.arn
  account_id        = data.aws_caller_identity.current.account_id
  config_role_names = local.config_role_names
  depends_on = [
    module.aws_recipes_s3_bucket_log_common
  ]
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
# For CloudTrail
#--------------------------------------------------------------
module "aws_recipes_s3_bucket_log_cloudtrail" {
  source        = "../../modules/aws/recipes/s3/bucket/log"
  bucket        = lookup(local.aws_s3_bucket_cloudtrail, "bucket")
  acl           = lookup(local.aws_s3_bucket_cloudtrail, "acl", "log-delivery-write")
  tags          = var.tags
  force_destroy = lookup(local.aws_s3_bucket_cloudtrail, "force_destroy", false)
  versioning = lookup(local.aws_s3_bucket_cloudtrail, "versioning", [
    {
      enabled = true
    }
    ]
  )
  logging = lookup(local.aws_s3_bucket_cloudtrail, "logging", [
    {
      target_bucket = module.aws_recipes_s3_bucket_log_common.id
      target_prefix = "AWSLogs/${data.aws_caller_identity.current.account_id}/CloudTrail/AccessLog/"
    }
  ])
  lifecycle_rule                       = lookup(local.aws_s3_bucket_cloudtrail, "lifecycle_rule", [])
  replication_configuration            = lookup(local.aws_s3_bucket_cloudtrail, "replication_configuration", [])
  server_side_encryption_configuration = lookup(local.aws_s3_bucket_cloudtrail, "server_side_encryption_configuration", [])
  object_lock_configuration            = lookup(local.aws_s3_bucket_cloudtrail, "object_lock_configuration", [])
  depends_on = [
    module.aws_recipes_s3_bucket_log_common,
  ]
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
# Policy for CloudTrail.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_cloudtrail_cloudtrail" {
  source     = "../../modules/aws/recipes/s3/policy/cloudtrail"
  bucket     = module.aws_recipes_s3_bucket_log_cloudtrail.id
  bucket_arn = module.aws_recipes_s3_bucket_log_cloudtrail.arn
  account_id = data.aws_caller_identity.current.account_id
  depends_on = [
    module.aws_recipes_s3_bucket_log_common,
    module.aws_recipes_s3_bucket_log_cloudtrail
  ]
}
