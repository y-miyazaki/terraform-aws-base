#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_s3_bucket_application = merge(var.common_log.aws_s3_bucket_application, { "bucket" = "${var.name_prefix}${var.common_log.aws_s3_bucket_application.bucket}-${random_id.this.dec}" })
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
# For application log.
#--------------------------------------------------------------
module "aws_recipes_s3_bucket_log_application" {
  source        = "../../modules/aws/recipes/s3/bucket/log"
  bucket        = lookup(local.aws_s3_bucket_application, "bucket")
  acl           = lookup(local.aws_s3_bucket_application, "acl", "private")
  tags          = var.tags
  force_destroy = lookup(local.aws_s3_bucket_application, "force_destroy", false)
  versioning = lookup(local.aws_s3_bucket_application, "versioning", [
    {
      enabled = true
    }
    ]
  )
  logging                              = lookup(local.aws_s3_bucket_application, "logging", [])
  lifecycle_rule                       = lookup(local.aws_s3_bucket_application, "lifecycle_rule", [])
  replication_configuration            = lookup(local.aws_s3_bucket_application, "replication_configuration", [])
  server_side_encryption_configuration = lookup(local.aws_s3_bucket_application, "server_side_encryption_configuration", [])
  object_lock_configuration            = lookup(local.aws_s3_bucket_application, "object_lock_configuration", [])
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
