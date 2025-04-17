#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  name_prefix = var.name_prefix == "" ? "" : "${trimsuffix(var.name_prefix, "-")}-"
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "acm-certificate-expiration-check" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}acm-certificate-expiration-check"
  description = "Checks whether ACM Certificates in your account are marked for expiration within the specified number of days. Certificates provided by ACM are automatically renewed. ACM does not automatically renew certificates that you import."
  source {
    owner             = "AWS"
    source_identifier = "ACM_CERTIFICATE_EXPIRATION_CHECK"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "api-gw-execution-logging-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}api-gw-execution-logging-enabled"
#   description = "Checks that all methods in Amazon API Gateway stage has logging enabled. The rule is NON_COMPLIANT if logging is not enabled. The rule is NON_COMPLIANT if loggingLevel is neither ERROR nor INFO."
#   source {
#     owner             = "AWS"
#     source_identifier = "API_GW_EXECUTION_LOGGING_ENABLED"
#   }
#   tags = local.tags
# }
