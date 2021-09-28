#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  name_prefix = var.name_prefix == "" ? "" : "${trimsuffix(var.name_prefix, "-")}-"
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudfront-accesslogs-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudfront-accesslogs-enabled"
  description = "Checks if Amazon CloudFront distributions are configured to capture information from Amazon Simple Storage Service (Amazon S3) server access logs. This rule is NON_COMPLIANT if a CloudFront distribution does not have logging configured."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_ACCESSLOGS_ENABLED"
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudfront-associated-with-waf" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudfront-associated-with-waf"
  description = "Checks if Amazon CloudFront distributions are associated with either WAF or WAFv2 web access control lists (ACLs). This rule is NON_COMPLIANT if a CloudFront distribution is not associated with a web ACL."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_ASSOCIATED_WITH_WAF"
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudfront-custom-ssl-certificate" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudfront-custom-ssl-certificate"
  description = "Checks if the certificate associated with an Amazon CloudFront distribution is the default Secure Sockets Layer (SSL) certificate. This rule is NON_COMPLIANT if a CloudFront distribution uses the default SSL certificate."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_CUSTOM_SSL_CERTIFICATE"
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudfront-default-root-object-configured" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudfront-default-root-object-configured"
  description = "Checks if an Amazon CloudFront distribution is configured to return a specific object that is the default root object. The rule is NON_COMPLIANT if Amazon CloudFront distribution does not have a default root object configured."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_DEFAULT_ROOT_OBJECT_CONFIGURED"
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudfront-origin-access-identity-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudfront-origin-access-identity-enabled"
  description = "Checks that Amazon CloudFront distribution with S3 Origin type has Origin Access Identity (OAI) configured. This rule is NON_COMPLIANT if the CloudFront distribution is backed by S3 and any of S3 Origin type is not OAI configured."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_ORIGIN_ACCESS_IDENTITY_ENABLED"
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudfront-origin-failover-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudfront-origin-failover-enabled"
  description = "Checks whether an origin group is configured for the distribution of at least 2 origins in the origin group for Amazon CloudFront. This rule is NON_COMPLIANT if there are no origin groups for the distribution."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_ORIGIN_FAILOVER_ENABLED"
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudfront-sni-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudfront-sni-enabled"
  description = "Checks if Amazon CloudFront distributions are using a custom SSL certificate and are configured to use SNI to serve HTTPS requests. This rule is NON_COMPLIANT if a custom SSL certificate is associated but the SSL support method is a dedicated IP address."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_SNI_ENABLED"
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudfront-viewer-policy-https" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudfront-viewer-policy-https"
  description = "Checks whether your Amazon CloudFront distributions use HTTPS (directly or via a redirection). The rule is NON_COMPLIANT if the value of ViewerProtocolPolicy is set to 'allow-all' for the defaultCacheBehavior or for the cacheBehaviors."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_VIEWER_POLICY_HTTPS"
  }
  tags = var.tags
}
