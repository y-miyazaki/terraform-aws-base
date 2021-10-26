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
}
#--------------------------------------------------------------
# Provides AWS Config.
#--------------------------------------------------------------
module "aws_recipes_security_config_create" {
  source                            = "../../modules/aws/recipes/security/config/create"
  is_enabled                        = lookup(var.security_config, "is_enabled", true)
  is_s3_enabled                     = lookup(var.security_config, "is_s3_enabled", false)
  aws_config_configuration_recorder = local.aws_config_configuration_recorder_config
  aws_iam_role                      = local.aws_iam_role_config
  #   aws_s3_bucket                     = local.aws_s3_bucket_config
  aws_s3_bucket_existing = {
    # The S3 bucket id
    bucket_id = module.aws_recipes_s3_bucket_log_common.id
    # The S3 bucket arn
    bucket_arn = module.aws_recipes_s3_bucket_log_common.arn
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
# Provides an AWS Config Rule for API Gateway
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_api_gateway" {
  source      = "../../modules/aws/recipes/security/config/rule/api_gateway"
  is_enabled  = lookup(var.security_config, "is_enabled", true)
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_recipes_security_config_create
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
    module.aws_recipes_security_config_create
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
    module.aws_recipes_security_config_create
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for EC2
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_ec2" {
  source      = "../../modules/aws/recipes/security/config/rule/ec2"
  is_enabled  = lookup(var.security_config, "is_enabled", true)
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_recipes_security_config_create
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for S3
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_s3" {
  source      = "../../modules/aws/recipes/security/config/rule/s3"
  is_enabled  = lookup(var.security_config, "is_enabled", true)
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_recipes_security_config_create
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
    source_arn          = module.aws_recipes_security_config_create.arn
    statement_id        = "configDetectUnexpectedUsage"
    statement_id_prefix = null
  }
  tags = var.tags
}
