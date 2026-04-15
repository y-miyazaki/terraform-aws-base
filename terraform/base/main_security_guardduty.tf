#--------------------------------------------------------------
# For GuardDuty
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a resource to manage a GuardDuty detector.
#--------------------------------------------------------------
module "aws_security_guardduty" {
  source     = "../../modules/aws/security/guardduty"
  is_enabled = var.security_guardduty.is_enabled && !local.control_tower_managed_services.guardduty

  aws_guardduty_detector = var.security_guardduty.aws_guardduty_detector
  aws_guardduty_member   = var.security_guardduty.aws_guardduty_member

  tags = var.tags
}
