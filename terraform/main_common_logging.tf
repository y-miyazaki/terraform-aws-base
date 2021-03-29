#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_s3_bucket_logging = merge(var.security_logging.aws_s3_bucket, { "bucket" = "${var.name_prefix}${var.security_logging.aws_s3_bucket.bucket}-${random_id.this.dec}" })
}
#--------------------------------------------------------------
# Provides a S3 bucket resource.
#--------------------------------------------------------------
module "aws_recipes_s3_bucket_log_logging" {
  source        = "../modules/aws/recipes/s3/bucket/log"
  bucket        = lookup(local.aws_s3_bucket_logging, "bucket")
  acl           = lookup(local.aws_s3_bucket_logging, "acl", "private")
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
#--------------------------------------------------------------
module "aws_recipes_s3_policy_custom_logging" {
  source = "../modules/aws/recipes/s3/policy/custom"
  bucket = module.aws_recipes_s3_bucket_log_logging.id
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
                "${module.aws_recipes_s3_bucket_log_logging.arn}",
                "${module.aws_recipes_s3_bucket_log_logging.arn}/*"
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
    module.aws_recipes_s3_bucket_log_logging
  ]
}
