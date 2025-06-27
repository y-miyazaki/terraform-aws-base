#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  s3_log_bucket        = "${var.name_prefix}${var.common_log.s3_log.bucket}-${data.aws_caller_identity.current.account_id}"
  s3_cloudtrail_bucket = "${var.name_prefix}${var.common_log.s3_cloudtrail.bucket}-${data.aws_caller_identity.current.account_id}"
  config_role_names = var.security_config.is_enabled && !var.use_control_tower ? var.security_config_us_east_1.is_enabled ? [
    module.aws_security_config_create_v4.config_role_name,
    # for CloudFront
    module.aws_security_config_create_v4_us_east_1.config_role_name,
    ] : [
    module.aws_security_config_create_v4.config_role_name,
  ] : []
}
#--------------------------------------------------------------
# S3 for log.
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#--------------------------------------------------------------
#tfsec:ignore:aws-s3-enable-versioning
module "s3_log" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "5.1.0"
  create_bucket = var.common_log.s3_log.create_bucket

  grant = [
    {
      type       = "CanonicalUser"
      permission = "FULL_CONTROL"
      id         = data.aws_canonical_user_id.current.id
    },
    {
      type       = "CanonicalUser"
      permission = "FULL_CONTROL"
      id         = data.aws_cloudfront_log_delivery_canonical_user_id.current.id
      # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
    },
  ]
  attach_access_log_delivery_policy        = true
  attach_analytics_destination_policy      = false
  attach_deny_incorrect_encryption_headers = false
  attach_deny_incorrect_kms_key_sse        = false
  attach_deny_insecure_transport_policy    = true
  attach_deny_unencrypted_object_uploads   = false
  attach_elb_log_delivery_policy           = false
  attach_inventory_destination_policy      = false
  attach_lb_log_delivery_policy            = false
  attach_policy                            = true
  attach_public_policy                     = var.common_log.s3_log.attach_public_policy
  attach_require_latest_tls_policy         = true
  block_public_acls                        = var.common_log.s3_log.block_public_acls
  block_public_policy                      = var.common_log.s3_log.block_public_policy
  bucket                                   = local.s3_log_bucket
  control_object_ownership                 = true
  force_destroy                            = var.common_log.s3_log.force_destroy
  ignore_public_acls                       = var.common_log.s3_log.ignore_public_acls
  lifecycle_rule                           = var.common_log.s3_log.lifecycle_rule
  logging                                  = {}
  object_ownership                         = "ObjectWriter"
  policy                                   = data.aws_iam_policy_document.s3_log_combined.json
  restrict_public_buckets                  = var.common_log.s3_log.restrict_public_buckets
  server_side_encryption_configuration     = var.common_log.s3_log.server_side_encryption_configuration
  tags                                     = var.tags
  versioning                               = var.common_log.s3_log.versioning
}

#--------------------------------------------------------------
# Provides a S3 bucket policy for Config.
# Policy for log.
#--------------------------------------------------------------
module "aws_s3_policy_config_log" {
  source               = "../../modules/aws/s3/bucket_policy/config"
  attach_bucket_policy = false
  bucket               = local.s3_log_bucket
  account_id           = data.aws_caller_identity.current.account_id
  config_role_names    = local.config_role_names
}

#--------------------------------------------------------------
# Provides a S3 bucket policy for Redshift.
# Policy for log.
#--------------------------------------------------------------
module "aws_s3_policy_redshift_log" {
  source               = "../../modules/aws/s3/bucket_policy/redshift"
  attach_bucket_policy = false
  bucket               = local.s3_log_bucket
}

#--------------------------------------------------------------
# Provides a S3 bucket policy for Redshift.
# Policy for log.
#--------------------------------------------------------------
module "aws_s3_policy_lb_log" {
  source               = "../../modules/aws/s3/bucket_policy/lb"
  attach_bucket_policy = false
  bucket               = local.s3_log_bucket
  elb_account_id       = var.common_log.elb_account_id
}

#--------------------------------------------------------------
# Provides a S3 bucket policy for Redshift.
# Policy for log.
#--------------------------------------------------------------
data "aws_iam_policy_document" "s3_log_combined" {
  source_policy_documents = compact([
    module.aws_s3_policy_config_log.policy_json,
    module.aws_s3_policy_lb_log.policy_json,
    module.aws_s3_policy_redshift_log.policy_json,
  ])
}

#--------------------------------------------------------------
# S3 for cloudtrail.
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#--------------------------------------------------------------
#tfsec:ignore:aws-s3-enable-versioning
module "s3_cloudtrail" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "5.1.0"
  create_bucket = var.common_log.s3_cloudtrail.create_bucket && !var.use_control_tower

  attach_access_log_delivery_policy        = true
  attach_analytics_destination_policy      = false
  attach_deny_incorrect_encryption_headers = false
  attach_deny_incorrect_kms_key_sse        = false
  attach_deny_insecure_transport_policy    = true
  attach_deny_unencrypted_object_uploads   = false
  attach_elb_log_delivery_policy           = false
  attach_inventory_destination_policy      = false
  attach_lb_log_delivery_policy            = false
  attach_policy                            = true
  attach_public_policy                     = var.common_log.s3_cloudtrail.attach_public_policy
  attach_require_latest_tls_policy         = true
  block_public_acls                        = var.common_log.s3_cloudtrail.block_public_acls
  block_public_policy                      = var.common_log.s3_cloudtrail.block_public_policy
  bucket                                   = local.s3_cloudtrail_bucket
  force_destroy                            = var.common_log.s3_cloudtrail.force_destroy
  ignore_public_acls                       = var.common_log.s3_cloudtrail.ignore_public_acls
  lifecycle_rule                           = var.common_log.s3_cloudtrail.lifecycle_rule
  logging = {
    target_bucket = module.s3_log.s3_bucket_id
    target_prefix = "AccessLogs/${data.aws_caller_identity.current.account_id}/S3/${local.s3_cloudtrail_bucket}/"
  }
  policy                               = module.aws_s3_policy_cloudtrail_cloudtrail.policy_json
  restrict_public_buckets              = var.common_log.s3_cloudtrail.restrict_public_buckets
  server_side_encryption_configuration = var.common_log.s3_cloudtrail.server_side_encryption_configuration
  tags                                 = var.tags
  versioning                           = var.common_log.s3_cloudtrail.versioning
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
# Policy for CloudTrail.
#--------------------------------------------------------------
module "aws_s3_policy_cloudtrail_cloudtrail" {
  source               = "../../modules/aws/s3/bucket_policy/cloudtrail"
  attach_bucket_policy = false
  bucket               = local.s3_cloudtrail_bucket
  account_id           = data.aws_caller_identity.current.account_id
}
