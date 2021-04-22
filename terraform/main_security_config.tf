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
  aws_iam_policy_config = merge(var.security_config.aws_iam_policy, {
    name = "${var.name_prefix}${lookup(var.security_config.aws_iam_policy, "name")}"
    }
  )
  aws_s3_bucket_config = merge(var.security_config.aws_s3_bucket, { bucket = "${var.name_prefix}${var.security_config.aws_s3_bucket.bucket}-${random_id.this.dec}" })
  aws_config_delivery_channel_config = merge(var.security_config.aws_config_delivery_channel, {
    name = "${var.name_prefix}${lookup(var.security_config.aws_config_delivery_channel, "name")}"
    }
  )
}
#--------------------------------------------------------------
# Provides AWS Config.
#--------------------------------------------------------------
module "aws_recipes_security_config_create" {
  source                                   = "../modules/aws/recipes/security/config/create"
  is_enabled                               = lookup(var.security_config, "is_enabled", true)
  aws_config_configuration_recorder        = local.aws_config_configuration_recorder_config
  aws_iam_role                             = local.aws_iam_role_config
  aws_iam_policy                           = local.aws_iam_policy_config
  aws_s3_bucket                            = local.aws_s3_bucket_config
  aws_config_delivery_channel              = local.aws_config_delivery_channel_config
  aws_config_configuration_recorder_status = lookup(var.security_config, "aws_config_configuration_recorder_status")
  account_id                               = data.aws_caller_identity.current.account_id
  tags                                     = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for API Gateway
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_api_gateway" {
  source      = "../modules/aws/recipes/security/config/rule/api_gateway"
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
  source      = "../modules/aws/recipes/security/config/rule/rds"
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
  source      = "../modules/aws/recipes/security/config/rule/load_balancer"
  is_enabled  = lookup(var.security_config, "is_enabled", true)
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_recipes_security_config_create
  ]
}
