#--------------------------------------------------------------
# For Athena
#--------------------------------------------------------------
#--------------------------------------------------------------
# Change the EncryptionConfiguration and ResultConfiguration of Athena's Workgroup(primary)
#--------------------------------------------------------------
module "aws_security_athena_us_east_1" {
  source     = "../../modules/aws/security/athena"
  is_enabled = !local.is_default_region_us_east_1 && var.security_athena.is_enabled
  providers = {
    aws = aws.us-east-1
  }

  output_location = format("s3://%s/Logs/Athena/", module.s3_log.s3_bucket_id)
}
