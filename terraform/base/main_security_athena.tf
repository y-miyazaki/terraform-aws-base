#--------------------------------------------------------------
# For Security Hub
#--------------------------------------------------------------
#--------------------------------------------------------------
# Change the EncryptionConfiguration setting of Athena's Workgroup(primary) to SSE_S3.
#--------------------------------------------------------------
module "aws_security_athena" {
  source     = "../../modules/aws/security/athena"
  is_enabled = lookup(var.security_athena, "is_enabled", true)
}
