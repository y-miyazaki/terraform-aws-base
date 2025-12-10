#--------------------------------------------------------------
# For Athena
#--------------------------------------------------------------
#--------------------------------------------------------------
# Change the EncryptionConfiguration and ResultConfiguration of Athena's Workgroup(primary)
#--------------------------------------------------------------
module "aws_security_athena" {
  source     = "../../modules/aws/security/athena"
  is_enabled = var.security_athena.is_enabled

  output_location = format("s3://%s/Logs/Athena/", module.s3_log.s3_bucket_id)
}
