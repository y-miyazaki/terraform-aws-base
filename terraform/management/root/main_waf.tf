#--------------------------------------------------------------
# WAF
# WAFv2 Web ACL definitions for API protection.
#--------------------------------------------------------------

#--------------------------------------------------------------
# WAF for JIT Access API Gateway
#--------------------------------------------------------------
module "waf_jit_access" {
  count  = var.jit_access.is_enabled ? 1 : 0
  source = "../../../modules/aws/waf"

  description = "WAF for JIT Access API Gateway"
  logging = {
    enabled           = true
    retention_in_days = coalesce(try(var.cloudwatch_log_group.override.jit_access.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
    kms_key_id        = module.kms_key["root"].key_arn
    logging_filter = {
      default_behavior = "DROP"
      filter = [
        {
          behavior = "KEEP"
          condition = [
            { action_condition = { action = "BLOCK" } },
            { action_condition = { action = "COUNT" } },
          ]
          requirement = "MEETS_ANY"
        },
      ]
    }
  }
  name  = "${var.name_prefix}jit-access-waf"
  scope = "REGIONAL"
  rules = [
    # Priority 1: IP reputation (WCU 25) - block known malicious IPs immediately
    {
      name            = "AWSManagedRulesAmazonIpReputationList"
      priority        = 1
      override_action = "none"
      managed_rule_group_statement = {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
      visibility_config = {
        metric_name = "${var.name_prefix}jit-access-ip-reputation"
      }
    },
    # Priority 2: Rate limit (WCU 2) - block flood attacks before heavy inspection
    {
      name     = "RateLimit"
      priority = 2
      action   = "block"
      rate_based_statement = {
        limit = 300
      }
      visibility_config = {
        metric_name = "${var.name_prefix}jit-access-rate-limit"
      }
    },
    # Priority 3: Known bad inputs (WCU 200) - block Log4j, SSRF, etc.
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet"
      priority        = 3
      override_action = "none"
      managed_rule_group_statement = {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
      visibility_config = {
        metric_name = "${var.name_prefix}jit-access-known-bad-inputs"
      }
    },
    # Priority 4: Common rule set (WCU 700) - OWASP Top 10, heaviest inspection last
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 4
      override_action = "none"
      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        rule_action_overrides = [
          {
            name          = "SizeRestrictions_BODY"
            action_to_use = { count = {} }
          },
        ]
      }
      visibility_config = {
        metric_name = "${var.name_prefix}jit-access-common-rules"
      }
    },
  ]
  visibility_config = {
    metric_name = "${var.name_prefix}jit-access-waf"
  }


  tags = var.tags
}
