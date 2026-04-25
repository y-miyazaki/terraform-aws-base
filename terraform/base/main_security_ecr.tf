#--------------------------------------------------------------
# For ECR Account Settings
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enforce ECR account-level security defaults.
# Migrates basic scan type to AWS native scanning technology.
#--------------------------------------------------------------
module "aws_security_ecr" {
  source     = "../../modules/aws/security/ecr"
  is_enabled = var.security_ecr.is_enabled
}
