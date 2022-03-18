#--------------------------------------------------------------
# For AWS Config
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_config_configuration_recorder_config = merge(var.security_config.aws_config_configuration_recorder, {
    name = "${var.name_prefix}${lookup(var.security_config.aws_config_configuration_recorder, "name")}"
    }
  )
  aws_iam_role_config = merge(var.security_config.aws_iam_role, {
    name = "${var.name_prefix}${lookup(var.security_config.aws_iam_role, "name")}"
    }
  )
  #   aws_s3_bucket_config = merge(var.security_config.aws_s3_bucket, { bucket = "${var.name_prefix}${var.security_config.aws_s3_bucket.bucket}-${random_id.this.dec}" })
  aws_config_delivery_channel_config = merge(var.security_config.aws_config_delivery_channel, {
    name = "${var.name_prefix}${lookup(var.security_config.aws_config_delivery_channel, "name")}"
    }
  )
  aws_iam_role_ssm_automation = merge(var.security_config.ssm_automation.aws_iam_role, {
    name = "${var.name_prefix}${lookup(var.security_config.ssm_automation.aws_iam_role, "name")}"
    }
  )
  aws_iam_policy_ssm_automation = merge(var.security_config.ssm_automation.aws_iam_policy, {
    name = "${var.name_prefix}${lookup(var.security_config.ssm_automation.aws_iam_policy, "name")}"
    }
  )
}
#--------------------------------------------------------------
# Provides AWS Config.
#--------------------------------------------------------------
module "aws_recipes_security_config_create_v4" {
  source                            = "../../modules/aws/recipes/security/config/create-v4"
  is_enabled                        = lookup(var.security_config, "is_enabled", true)
  is_s3_enabled                     = lookup(var.security_config, "is_s3_enabled", false)
  aws_config_configuration_recorder = local.aws_config_configuration_recorder_config
  aws_iam_role                      = local.aws_iam_role_config
  #   aws_s3_bucket                     = local.aws_s3_bucket_config
  aws_s3_bucket_existing = {
    # The S3 bucket id
    bucket_id = module.aws_recipes_s3_bucket_log_v4_common.id
    # The S3 bucket arn
    bucket_arn = module.aws_recipes_s3_bucket_log_v4_common.arn
  }
  aws_config_delivery_channel              = local.aws_config_delivery_channel_config
  aws_config_configuration_recorder_status = lookup(var.security_config, "aws_config_configuration_recorder_status")
  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${lookup(var.security_config.aws_cloudwatch_event_rule, "name", "security-©-cloudwatch-event-rule")}"
    description = lookup(var.security_config.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for Config.")
  }
  aws_cloudwatch_event_target = {
    arn = module.aws_recipes_lambda_create_config.arn
  }
  account_id = data.aws_caller_identity.current.account_id
  tags       = var.tags
}
#--------------------------------------------------------------
# Create SSM Automation Role
#--------------------------------------------------------------
module "aws_recipes_security_config_ssm_automation" {
  source         = "../../modules/aws/recipes/security/config/ssm_automation"
  is_enabled     = lookup(var.security_config, "is_enabled", true)
  aws_iam_role   = local.aws_iam_role_ssm_automation
  aws_iam_policy = local.aws_iam_policy_ssm_automation
  tags           = var.tags
}

#--------------------------------------------------------------
# Provides an AWS Config Rule for API Gateway
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_api_gateway" {
  source      = "../../modules/aws/recipes/security/config/rule/api_gateway"
  is_enabled  = lookup(var.security_config, "is_enabled", true)
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_recipes_security_config_create_v4
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for RDS
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_rds" {
  source      = "../../modules/aws/recipes/security/config/rule/rds"
  is_enabled  = lookup(var.security_config, "is_enabled", true)
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_recipes_security_config_create_v4
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for Load Balancer
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_load_balancer" {
  source      = "../../modules/aws/recipes/security/config/rule/load_balancer"
  is_enabled  = lookup(var.security_config, "is_enabled", true)
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_recipes_security_config_create_v4
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for EC2
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_ec2" {
  source                                      = "../../modules/aws/recipes/security/config/rule/ec2"
  is_enabled                                  = lookup(var.security_config, "is_enabled", true)
  name_prefix                                 = var.name_prefix
  ssm_automation_assume_role_arn              = module.aws_recipes_security_config_ssm_automation.role_arn
  is_disable_public_access_for_security_group = lookup(var.security_config.remediation.ec2, "is_disable_public_access_for_security_group", false)
  tags                                        = var.tags
  depends_on = [
    module.aws_recipes_security_config_create_v4
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for S3
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_s3" {
  source                              = "../../modules/aws/recipes/security/config/rule/s3"
  is_enabled                          = lookup(var.security_config, "is_enabled", true)
  name_prefix                         = var.name_prefix
  ssm_automation_assume_role_arn      = module.aws_recipes_security_config_ssm_automation.role_arn
  is_configure_s3_public_access_block = lookup(var.security_config.remediation.s3, "is_configure_s3_public_access_block", false)
  configure_s3_public_access_block = lookup(var.security_config.remediation.s3, "configure_s3_public_access_block",
    {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
  })
  is_configure_s3_bucket_public_access_block = lookup(var.security_config.remediation.s3, "is_configure_s3_bucket_public_access_block", false)
  configure_s3_bucket_public_access_block = lookup(var.security_config.remediation.s3, "configure_s3_bucket_public_access_block",
    {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
  })
  is_disable_s3_bucket_public_read_write     = lookup(var.security_config.remediation.s3, "is_disable_s3_bucket_public_read_write", false)
  is_enabled_s3_bucket_encryption            = lookup(var.security_config.remediation.s3, "is_enabled_s3_bucket_encryption", false)
  enabled_s3_bucket_encryption_sse_algorithm = lookup(var.security_config.remediation.s3, "enabled_s3_bucket_encryption_sse_algorithm", "AES256")
  is_restrict_bucket_ssl_requests_only       = lookup(var.security_config.remediation.s3, "is_restrict_bucket_ssl_requests_only", false)
  is_configure_s3_bucket_versioning          = lookup(var.security_config.remediation.s3, "is_configure_s3_bucket_versioning", false)
  tags                                       = var.tags
  depends_on = [
    module.aws_recipes_security_config_create_v4
  ]
}

#--------------------------------------------------------------
# Create Lambda function
#--------------------------------------------------------------
module "aws_recipes_lambda_create_config" {
  source                   = "../../modules/aws/recipes/lambda/create"
  is_enabled               = lookup(var.security_config, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.security_config, "aws_cloudwatch_log_group_lambda")
  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/cloudwatch_event_config_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-event-config"
    dead_letter_config             = []
    handler                        = "cloudwatch_event_config_to_slack"
    role                           = module.aws_recipes_iam_lambda.arn
    description                    = "This program sends the result of config to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/cloudwatch_event_config_to_slack.zip")
    environment                    = lookup(var.security_config.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    principal           = "events.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_security_config_create_v4.arn
    statement_id        = "configDetectUnexpectedUsage"
    statement_id_prefix = null
  }
  tags = var.tags
}
