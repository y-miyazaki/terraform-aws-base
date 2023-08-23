#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  s3_log_bucket        = "${var.name_prefix}${var.common_log.s3_log.bucket}-${random_id.this.dec}"
  s3_cloudtrail_bucket = "${var.name_prefix}${var.common_log.s3_cloudtrail.bucket}-${random_id.this.dec}"
  config_role_names = var.security_config.is_enabled ? var.security_config_us_east_1.is_enabled ? [
    module.aws_recipes_security_config_create_v4.config_role_name,
    # for CloudFront
    module.aws_recipes_security_config_create_v4_us_east_1.config_role_name,
    ] : [
    module.aws_recipes_security_config_create_v4.config_role_name,
  ] : []
}
#--------------------------------------------------------------
# S3 for log.
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#--------------------------------------------------------------
#tfsec:ignore:aws-s3-enable-versioning
module "s3_log" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "3.15.0"
  create_bucket = var.common_log.s3_log.create_bucket

  acl                                  = var.common_log.s3_log.acl
  attach_public_policy                 = var.common_log.s3_log.attach_public_policy
  block_public_acls                    = var.common_log.s3_log.block_public_acls
  block_public_policy                  = var.common_log.s3_log.block_public_policy
  bucket                               = local.s3_log_bucket
  force_destroy                        = var.common_log.s3_log.force_destroy
  ignore_public_acls                   = var.common_log.s3_log.ignore_public_acls
  lifecycle_rule                       = var.common_log.s3_log.lifecycle_rule
  logging                              = {}
  restrict_public_buckets              = var.common_log.s3_log.restrict_public_buckets
  server_side_encryption_configuration = var.common_log.s3_log.server_side_encryption_configuration
  tags                                 = var.tags
  versioning                           = var.common_log.s3_log.versioning
}
#--------------------------------------------------------------
# Provides a S3 bucket policy.
# Policy for log.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_security_log" {
  source               = "../../modules/aws/recipes/s3/policy/security"
  attach_bucket_policy = false
  bucket               = module.s3_log.s3_bucket_id
  bucket_arn           = module.s3_log.s3_bucket_arn
  depends_on = [
    module.s3_log
  ]
}
#--------------------------------------------------------------
# Provides a S3 bucket policy.
# Policy for log.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_config_log" {
  source               = "../../modules/aws/recipes/s3/policy/config"
  attach_bucket_policy = false
  bucket               = module.s3_log.s3_bucket_id
  bucket_arn           = module.s3_log.s3_bucket_arn
  account_id           = data.aws_caller_identity.current.account_id
  config_role_names    = local.config_role_names
  depends_on = [
    module.s3_log
  ]
}
#--------------------------------------------------------------
# Provides a S3 bucket policy.
# Policy for log.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_lb_log_log" {
  source               = "../../modules/aws/recipes/s3/policy/lb_log"
  attach_bucket_policy = false
  bucket               = module.s3_log.s3_bucket_id
  bucket_arn           = module.s3_log.s3_bucket_arn
  depends_on = [
    module.s3_log
  ]
}
#--------------------------------------------------------------
# Provides a S3 bucket policy.
# Policy for log.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_access_log_log" {
  source               = "../../modules/aws/recipes/s3/policy/access_log"
  attach_bucket_policy = false
  bucket               = module.s3_log.s3_bucket_id
  bucket_arn           = module.s3_log.s3_bucket_arn
  depends_on = [
    module.s3_log
  ]
}
#--------------------------------------------------------------
# S3 bucket policy combined for log.
#--------------------------------------------------------------
data "aws_iam_policy_document" "log" {
  source_policy_documents = compact([
    module.aws_recipes_s3_policy_security_log.policy_json,
    module.aws_recipes_s3_policy_config_log.policy_json,
    module.aws_recipes_s3_policy_lb_log_log.policy_json,
    module.aws_recipes_s3_policy_access_log_log.policy_json,
  ])
}
resource "aws_s3_bucket_policy" "log" {
  bucket = module.s3_log.s3_bucket_id
  policy = data.aws_iam_policy_document.log.json
}

#--------------------------------------------------------------
# S3 for cloudtrail.
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#--------------------------------------------------------------
#tfsec:ignore:aws-s3-enable-versioning
module "s3_cloudtrail" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "3.15.0"
  create_bucket = var.common_log.s3_cloudtrail.create_bucket

  acl                  = var.common_log.s3_cloudtrail.acl
  attach_public_policy = var.common_log.s3_cloudtrail.attach_public_policy
  block_public_acls    = var.common_log.s3_cloudtrail.block_public_acls
  block_public_policy  = var.common_log.s3_cloudtrail.block_public_policy
  bucket               = local.s3_cloudtrail_bucket
  force_destroy        = var.common_log.s3_cloudtrail.force_destroy
  ignore_public_acls   = var.common_log.s3_cloudtrail.ignore_public_acls
  lifecycle_rule       = var.common_log.s3_cloudtrail.lifecycle_rule
  logging = {
    target_bucket = module.s3_log.s3_bucket_id
    target_prefix = "AccessLogs/${data.aws_caller_identity.current.account_id}/${local.s3_cloudtrail_bucket}/"
  }
  restrict_public_buckets              = var.common_log.s3_cloudtrail.restrict_public_buckets
  server_side_encryption_configuration = var.common_log.s3_cloudtrail.server_side_encryption_configuration
  tags                                 = var.tags
  versioning                           = var.common_log.s3_cloudtrail.versioning
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
# Policy for CloudTrail.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_cloudtrail_cloudtrail" {
  source               = "../../modules/aws/recipes/s3/policy/cloudtrail"
  attach_bucket_policy = false
  bucket               = module.s3_cloudtrail.s3_bucket_id
  bucket_arn           = module.s3_cloudtrail.s3_bucket_arn
  account_id           = data.aws_caller_identity.current.account_id
  depends_on = [
    module.s3_cloudtrail
  ]
}
#--------------------------------------------------------------
# Provides a S3 bucket policy.
# Policy for CloudTrail.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_security_cloudtrail" {
  source               = "../../modules/aws/recipes/s3/policy/security"
  attach_bucket_policy = false
  bucket               = module.s3_cloudtrail.s3_bucket_id
  bucket_arn           = module.s3_cloudtrail.s3_bucket_arn
  depends_on = [
    module.s3_cloudtrail
  ]
}
#--------------------------------------------------------------
# S3 bucket policy combined for cloudtrail.
#--------------------------------------------------------------
data "aws_iam_policy_document" "cloudtrail" {
  source_policy_documents = compact([
    module.aws_recipes_s3_policy_security_cloudtrail.policy_json,
    module.aws_recipes_s3_policy_cloudtrail_cloudtrail.policy_json,
  ])
}
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = module.s3_cloudtrail.s3_bucket_id
  policy = data.aws_iam_policy_document.cloudtrail.json
}
