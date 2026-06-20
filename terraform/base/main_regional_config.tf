#############################################################################
# Security: AWS Config (Multi-Region)
#############################################################################
# AWS Config deployment across multiple regions using AWS Provider v6+ region attribute

module "aws_security_config_create" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/config/create"

  is_enabled = (
    var.security_config.is_enabled &&
    !local.control_tower_managed_services.config
  )
  region = each.value


  # AWS Config Configuration Recorder
  aws_config_configuration_recorder = try(var.security_config.aws_config_configuration_recorder, {})

  # AWS Config Configuration Recorder Status
  aws_config_configuration_recorder_status = try(var.security_config.aws_config_configuration_recorder_status, {})

  # AWS Config Delivery Channel
  aws_config_delivery_channel = try(var.security_config.aws_config_delivery_channel, {})

  # S3 bucket configuration
  is_s3_enabled = try(var.security_config.is_s3_enabled, false)
  s3_bucket = try(var.security_config.aws_s3_bucket, {
    bucket                               = "config"
    lifecycle_rule                       = []
    logging                              = {}
    server_side_encryption_configuration = {}
    versioning                           = {}
  })
  aws_s3_bucket_existing = try(var.security_config.aws_s3_bucket_existing, null)

  # CloudWatch Event Rule and Target
  aws_cloudwatch_event_rule = try(var.security_config.aws_cloudwatch_event_rule, {})
  aws_cloudwatch_event_target = try(var.security_config.aws_cloudwatch_event_target, {
    arn = ""
  })

  # Tags
  tags = var.tags
}

# AWS Config Rules for S3
module "aws_security_config_rule_s3" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/config/rule/s3"

  is_enabled = (
    var.security_config.is_enabled &&
    !local.control_tower_managed_services.config
  )
  region = each.value

  # Config rules configuration
  name_prefix = var.name_prefix

  # SSM automation role
  ssm_automation_assume_role_arn = try(var.security_config.ssm_automation_assume_role_arn, "")

  # Tags
  tags = var.tags
}
