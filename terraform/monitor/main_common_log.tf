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
module "s3_application_log" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "3.2.1"
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
