#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  name_prefix = var.name_prefix == "" ? "" : "${trimsuffix(var.name_prefix, "-")}-"
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "api-gw-endpoint-type-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}api-gw-endpoint-type-check"
#   description = "Checks that Amazon API Gateway APIs are of type as specified in the rule parameter 'endpointConfigurationTypes'. The rule returns COMPLIANT if any of the RestApi endpoint types matches the endpointConfigurationTypes configured in the rule parameter."
#   source {
#     owner             = "AWS"
#     source_identifier = "API_GW_ENDPOINT_TYPE_CHECK"
#   }
#   tags = var.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "api-gw-xray-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}api-gw-xray-enabled"
  description = "Checks if AWS X-Ray tracing is enabled on Amazon API Gateway REST APIs. The rule is COMPLIANT if X-Ray tracing is enabled and NON_COMPLIANT otherwise."
  source {
    owner             = "AWS"
    source_identifier = "API_GW_XRAY_ENABLED"
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "api-gw-execution-logging-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}api-gw-execution-logging-enabled"
#   description = "Checks that all methods in Amazon API Gateway stage has logging enabled. The rule is NON_COMPLIANT if logging is not enabled. The rule is NON_COMPLIANT if loggingLevel is neither ERROR nor INFO."
#   source {
#     owner             = "AWS"
#     source_identifier = "API_GW_EXECUTION_LOGGING_ENABLED"
#   }
#   tags = var.tags
# }
