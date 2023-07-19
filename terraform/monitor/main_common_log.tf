#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  s3_application_log_bucket = "${var.name_prefix}${var.common_log.s3_application_log.bucket}-${random_id.this.dec}"
}

#--------------------------------------------------------------
# S3 for application log
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#--------------------------------------------------------------
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-block-public-policy
#tfsec:ignore:aws-s3-ignore-public-acls
#tfsec:ignore:aws-s3-no-public-buckets
#tfsec:ignore:aws-s3-block-public-acls
#tfsec:ignore:aws-s3-specify-public-access-block
module "s3_application_log" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "3.14.1"
  create_bucket = var.common_log.s3_application_log.create_bucket

  acl                                   = var.common_log.s3_application_log.acl
  attach_deny_insecure_transport_policy = var.common_log.s3_application_log.attach_deny_insecure_transport_policy
  attach_elb_log_delivery_policy        = var.common_log.s3_application_log.attach_elb_log_delivery_policy
  attach_lb_log_delivery_policy         = var.common_log.s3_application_log.attach_lb_log_delivery_policy
  attach_policy                         = var.common_log.s3_application_log.attach_policy
  attach_public_policy                  = var.common_log.s3_application_log.attach_public_policy
  attach_require_latest_tls_policy      = var.common_log.s3_application_log.attach_require_latest_tls_policy
  block_public_acls                     = var.common_log.s3_application_log.block_public_acls
  block_public_policy                   = var.common_log.s3_application_log.block_public_policy
  bucket                                = local.s3_application_log_bucket
  force_destroy                         = var.common_log.s3_application_log.force_destroy
  ignore_public_acls                    = var.common_log.s3_application_log.ignore_public_acls
  lifecycle_rule                        = var.common_log.s3_application_log.lifecycle_rule
  logging                               = var.common_log.s3_application_log.logging
  restrict_public_buckets               = var.common_log.s3_application_log.restrict_public_buckets
  server_side_encryption_configuration  = var.common_log.s3_application_log.server_side_encryption_configuration
  tags                                  = var.tags
  versioning                            = var.common_log.s3_application_log.versioning
}

#--------------------------------------------------------------
# S3 notification for CloudFront
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest/submodules/notification
#--------------------------------------------------------------
module "s3_application_log_notification_cloudfront" {
  source      = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version     = "3.14.1"
  bucket      = module.s3_application_log.s3_bucket_id
  eventbridge = true

  lambda_notifications = {
    lambda_notifications_cloudfront_logs = {
      function_arn  = module.aws_recipes_lambda_create_lambda_s3_notification_s3_object_created_for_athena.arn
      function_name = module.aws_recipes_lambda_create_lambda_s3_notification_s3_object_created_for_athena.function_name
      events = [
        "s3:ObjectCreated:Put",
        "s3:ObjectCreated:Post"
      ]
      source_account = data.aws_caller_identity.current.account_id
      filter_prefix  = "Logs/CloudFront"
      filter_suffix  = ".gz"
    }
  }
}
