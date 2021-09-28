#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_s3_bucket_logging = merge(var.common_logging.aws_s3_bucket, { "bucket" = "${var.name_prefix}${var.common_logging.aws_s3_bucket.bucket}-${random_id.this.dec}" })
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
#--------------------------------------------------------------
module "aws_recipes_s3_bucket_log_logging" {
  source        = "../../modules/aws/recipes/s3/bucket/log"
  bucket        = lookup(local.aws_s3_bucket_logging, "bucket")
  acl           = lookup(local.aws_s3_bucket_logging, "acl", "log-delivery-write")
  tags          = var.tags
  force_destroy = lookup(local.aws_s3_bucket_logging, "force_destroy", false)
  versioning = lookup(local.aws_s3_bucket_logging, "versioning", [
    {
      enabled = true
    }
    ]
  )
  logging                              = lookup(local.aws_s3_bucket_logging, "logging", [])
  lifecycle_rule                       = lookup(local.aws_s3_bucket_logging, "lifecycle_rule", [])
  replication_configuration            = lookup(local.aws_s3_bucket_logging, "replication_configuration", [])
  server_side_encryption_configuration = lookup(local.aws_s3_bucket_logging, "server_side_encryption_configuration", [])
  object_lock_configuration            = lookup(local.aws_s3_bucket_logging, "object_lock_configuration", [])
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
# Policy for CloudTrail and Config.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_custom_logging" {
  source            = "../../modules/aws/recipes/s3/policy/security"
  bucket            = module.aws_recipes_s3_bucket_log_logging.id
  bucket_arn        = module.aws_recipes_s3_bucket_log_logging.arn
  account_id        = data.aws_caller_identity.current.account_id
  config_role_names = local.config_role_names
  depends_on = [
    module.aws_recipes_s3_bucket_log_logging
  ]
}
