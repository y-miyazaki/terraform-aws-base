#--------------------------------------------------------------
# Module: aws/_internal/security_service_disable_alarm
# Purpose: CloudTrail metric filter and alarm that fire when a security service (GuardDuty, Security Hub, Macie, Inspector, Access Analyzer)
#          is disabled, deleted or detached from its administrator account.
# Notes: Internal helper shared by security/cloudtrail/cloudtrail and security/cloudtrail/controltower; not intended for direct use.
#        CloudWatch.1-14 do not cover these calls. Disable calls are listed by name (not Disable*) so that benign calls such as
#        DisableImportFindingsForProduct do not match. Denied attempts are matched too. The pattern must stay within 1024 characters.
#--------------------------------------------------------------
locals {
  pattern = join(" || ", [
    "{((($.eventSource=\"guardduty.amazonaws.com\") || ($.eventSource=\"securityhub.amazonaws.com\") || ($.eventSource=\"macie2.amazonaws.com\") || ($.eventSource=\"inspector2.amazonaws.com\")) && (($.eventName=\"Disassociate*\") || ($.eventName=\"DeleteMember*\") || ($.eventName=\"DisableOrganizationAdminAccount\")))",
    "(($.eventSource=\"guardduty.amazonaws.com\") && (($.eventName=\"DeleteDetector\") || ($.eventName=\"StopMonitoringMembers\") || (($.eventName=\"UpdateDetector\") && ($.requestParameters.enable IS FALSE))))",
    "(($.eventSource=\"securityhub.amazonaws.com\") && (($.eventName=\"BatchDisableStandards\") || ($.eventName=\"DisableSecurityHub\")))",
    "(($.eventSource=\"macie2.amazonaws.com\") && ($.eventName=\"DisableMacie\"))",
    "(($.eventSource=\"access-analyzer.amazonaws.com\") && ($.eventName=\"DeleteAnalyzer\"))",
    "(($.eventSource=\"inspector2.amazonaws.com\") && (($.eventName=\"Disable\") || ($.eventName=\"DisableDelegatedAdminAccount\")))}",
  ])
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "this" {
  count = var.is_enabled ? 1 : 0

  region         = var.region
  log_group_name = var.log_group_name
  name           = "${var.name_prefix}security-service-disable"
  pattern        = local.pattern

  metric_transformation {
    name      = "${var.name_prefix}security-service-disable"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# Provides a CloudWatch Metric Alarm resource.
# Fires on a single matching call. No ok_actions: there is nothing to recover from.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this" {
  count = var.is_enabled ? 1 : 0

  region                    = var.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "[Security] A security service (GuardDuty, Security Hub, Macie, Inspector or Access Analyzer) was disabled, deleted or detached from its administrator account."
  alarm_name                = "${var.name_prefix}security-service-disable"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  insufficient_data_actions = []
  metric_name               = aws_cloudwatch_log_metric_filter.this[0].metric_transformation[0].name
  namespace                 = aws_cloudwatch_log_metric_filter.this[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  treat_missing_data        = "notBreaching"

  tags = var.tags
}
