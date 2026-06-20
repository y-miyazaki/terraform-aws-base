#--------------------------------------------------------------
# For SSM Automation
#--------------------------------------------------------------
# Enable CloudWatch logging for SSM Automation to comply with SSM.6 control
# https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-action-logging.html

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

# Create CloudWatch Log Group for SSM Automation
resource "aws_cloudwatch_log_group" "ssm_automation" {
  count = var.is_enabled ? 1 : 0

  region            = local.region
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}

# Set the log destination to CloudWatch
# SSM.6 control
resource "aws_ssm_service_setting" "automation_log_destination" {
  count = var.is_enabled ? 1 : 0

  region        = local.region
  setting_id    = "/ssm/automation/customer-script-log-destination"
  setting_value = "CloudWatch"

  depends_on = [aws_cloudwatch_log_group.ssm_automation]
}

# Set the log group name for SSM Automation
resource "aws_ssm_service_setting" "automation_log_group_name" {
  count = var.is_enabled ? 1 : 0

  region        = local.region
  setting_id    = "/ssm/automation/customer-script-log-group-name"
  setting_value = var.cloudwatch_log_group_name

  depends_on = [aws_cloudwatch_log_group.ssm_automation]
}

# Disable public sharing of SSM Automation documents
# SSM.7 control
# https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-automation-sharing.html
resource "aws_ssm_service_setting" "automation_public_sharing_permission" {
  count = var.is_enabled ? 1 : 0

  region        = local.region
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}
