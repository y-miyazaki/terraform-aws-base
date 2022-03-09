#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_s3_bucket = merge(var.common_log.aws_s3_bucket_application.aws_s3_bucket, { "bucket" = "${var.name_prefix}${var.common_log.aws_s3_bucket_application.aws_s3_bucket.bucket}-${random_id.this.dec}" })
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
# For application log.
#--------------------------------------------------------------
module "aws_recipes_s3_bucket_log_application" {
  source        = "../../modules/aws/recipes/s3/bucket/log-v4"
  tags          = var.tags
  aws_s3_bucket = local.aws_s3_bucket
  aws_s3_bucket_acl = lookup(var.common_log.aws_s3_bucket_application, "aws_s3_bucket_acl", {
    acl = "log-delivery-write"
    }
  )
  aws_s3_bucket_versioning = lookup(var.common_log.aws_s3_bucket_application, "aws_s3_bucket_versioning", {
    versioning_configuration = [
      {
        status     = "Enabled"
        mfa_delete = "Disabled"
      }
    ]
    }
  )
  aws_s3_bucket_logging                              = lookup(var.common_log.aws_s3_bucket_application, "aws_s3_bucket_logging", null)
  aws_s3_bucket_lifecycle_configuration              = lookup(var.common_log.aws_s3_bucket_application, "aws_s3_bucket_lifecycle_configuration")
  aws_s3_bucket_server_side_encryption_configuration = lookup(var.common_log.aws_s3_bucket_application, "aws_s3_bucket_server_side_encryption_configuration", null)
  s3_replication_configuration_role_arn              = lookup(var.common_log.aws_s3_bucket_application, "s3_replication_configuration_role_arn", null)
  aws_s3_bucket_replication_configuration            = lookup(var.common_log.aws_s3_bucket_application, "aws_s3_bucket_replication_configuration", null)
}

#--------------------------------------------------------------
# Provides a S3 bucket resource.
#--------------------------------------------------------------
module "aws_recipes_s3_policy_custom_log" {
  source = "../../modules/aws/recipes/s3/policy/custom"
  bucket = module.aws_recipes_s3_bucket_log_application.id
  policy = <<POLICY
{
    "Id": "ExamplePolicy",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Action": "s3:*",
            "Effect": "Deny",
            "Resource": [
                "${module.aws_recipes_s3_bucket_log_application.arn}",
                "${module.aws_recipes_s3_bucket_log_application.arn}/*"
            ],
            "Condition": {
                "Bool": {
                     "aws:SecureTransport": "false"
                }
            },
           "Principal": "*"
        }
    ]
}
POLICY
  depends_on = [
    module.aws_recipes_s3_bucket_log_application
  ]
}
