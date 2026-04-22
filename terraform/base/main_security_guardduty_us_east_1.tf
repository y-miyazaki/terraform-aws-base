#--------------------------------------------------------------
# For GuardDuty (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a resource to manage a GuardDuty detector in us-east-1.
#--------------------------------------------------------------
module "aws_security_guardduty_us_east_1" {
  source     = "../../modules/aws/security/guardduty"
  is_enabled = local.is_enabled_us_east_1 && var.security_guardduty_us_east_1.is_enabled && !local.control_tower_managed_services.guardduty
  providers = {
    aws = aws.us-east-1
  }

  aws_guardduty_detector = var.security_guardduty_us_east_1.aws_guardduty_detector
  aws_guardduty_member   = var.security_guardduty_us_east_1.aws_guardduty_member

  tags = var.tags
}
