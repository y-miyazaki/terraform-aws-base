#--------------------------------------------------------------
# For ECR Account Settings (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enforce ECR account-level security defaults.
# Migrates basic scan type to AWS native scanning technology.
#--------------------------------------------------------------
module "aws_security_ecr_us_east_1" {
  source     = "../../modules/aws/security/ecr"
  is_enabled = local.is_enabled_us_east_1 && var.security_ecr.is_enabled
  providers = {
    aws = aws.us-east-1
  }
}
