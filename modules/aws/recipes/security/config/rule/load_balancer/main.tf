#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  name_prefix = var.name_prefix == "" ? "" : "${trimsuffix(var.name_prefix, "-")}-"
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "alb-http-drop-invalid-header-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}alb-http-drop-invalid-header-enabled"
#   description = "Checks if rule evaluates AWS Application Load Balancers (ALB) to ensure they are configured to drop http headers. The rule is NON_COMPLIANT if the value of routing.http.drop_invalid_header_fields.enabled is set to false."
#   source {
#     owner             = "AWS"
#     source_identifier = "ALB_HTTP_DROP_INVALID_HEADER_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "alb-http-to-https-redirection-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}alb-http-to-https-redirection-check"
#   description = "Checks whether HTTP to HTTPS redirection is configured on all HTTP listeners of Application Load Balancers. The rule is NON_COMPLIANT if one or more HTTP listeners of Application Load Balancer do not have HTTP to HTTPS redirection configured."
#   source {
#     owner             = "AWS"
#     source_identifier = "ALB_HTTP_TO_HTTPS_REDIRECTION_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "alb-waf-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}alb-waf-enabled"
  description = "Checks if Web Application Firewall (WAF) is enabled on Application Load Balancers (ALBs). This rule is NON_COMPLIANT if key: waf.enabled is set to false."
  source {
    owner             = "AWS"
    source_identifier = "ALB_WAF_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "autoscaling-group-elb-healthcheck-required" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}autoscaling-group-elb-healthcheck-required"
#   description = "Checks whether your Auto Scaling groups that are associated with a load balancer are using Elastic Load Balancing health checks."
#   source {
#     owner             = "AWS"
#     source_identifier = "AUTOSCALING_GROUP_ELB_HEALTHCHECK_REQUIRED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "elb-acm-certificate-required" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}elb-acm-certificate-required"
  description = "This rule checks whether the Elastic Load Balancer(s) uses SSL certificates provided by AWS Certificate Manager. You must use an SSL or HTTPS listener with your Elastic Load Balancer to use this rule."
  source {
    owner             = "AWS"
    source_identifier = "ELB_ACM_CERTIFICATE_REQUIRED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "elb-cross-zone-load-balancing-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}elb-cross-zone-load-balancing-enabled"
  description = "Checks if cross-zone load balancing is enabled for the Classic Load Balancers (CLBs). This rule is NON_COMPLIANT if cross-zone load balancing is not enabled for a CLB."
  source {
    owner             = "AWS"
    source_identifier = "ELB_CROSS_ZONE_LOAD_BALANCING_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "elb-custom-security-policy-ssl-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}elb-custom-security-policy-ssl-check"
#   description = "Checks whether your Classic Load Balancer SSL listeners are using a custom policy. The rule is only applicable if there are SSL listeners for the Classic Load Balancer."
#   source {
#     owner             = "AWS"
#     source_identifier = "ELB_CUSTOM_SECURITY_POLICY_SSL_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "elb-deletion-protection-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}elb-deletion-protection-enabled"
#   description = "Checks whether an Elastic Load Balancer has deletion protection enabled. The rule is NON_COMPLIANT if deletion_protection.enabled is false."
#   source {
#     owner             = "AWS"
#     source_identifier = "ELB_DELETION_PROTECTION_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "elb-logging-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}elb-logging-enabled"
#   description = "Checks whether the Application Load Balancers and the Classic Load Balancers have logging enabled."
#   source {
#     owner             = "AWS"
#     source_identifier = "ELB_LOGGING_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "elb-predefined-security-policy-ssl-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}elb-predefined-security-policy-ssl-check"
#   description = "Checks whether your Classic Load Balancer SSL listeners are using a predefined policy. The rule is only applicable if there are SSL listeners for the Classic Load Balancer."
#   source {
#     owner             = "AWS"
#     source_identifier = "ELB_PREDEFINED_SECURITY_POLICY_SSL_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "elb-tls-https-listeners-only" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}elb-tls-https-listeners-only"
#   description = "Checks whether your Classic Load Balancer's listeners are configured with SSL or HTTPS"
#   source {
#     owner             = "AWS"
#     source_identifier = "ELB_TLS_HTTPS_LISTENERS_ONLY"
#   }
#   tags = local.tags
# }
