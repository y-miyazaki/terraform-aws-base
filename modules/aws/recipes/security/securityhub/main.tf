#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  region = var.region == null ? data.aws_region.current.name : var.region
}
#--------------------------------------------------------------
# Current Region
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
resource "aws_securityhub_account" "this" {
  count = var.is_enabled ? 1 : 0
}
#--------------------------------------------------------------
# Provides a Security Hub member resource.
#--------------------------------------------------------------
resource "aws_securityhub_member" "this" {
  for_each   = var.is_enabled ? var.aws_securityhub_member : {}
  account_id = each.value.account_id
  email      = each.value.email
  invite     = each.value.invite
  depends_on = [
    aws_securityhub_account.this
  ]
}
#--------------------------------------------------------------
# Subscribes to a Security Hub product.
#--------------------------------------------------------------
resource "aws_securityhub_product_subscription" "this" {
  for_each    = var.is_enabled ? var.aws_securityhub_product_subscription : {}
  product_arn = each.value.product_arn
  depends_on = [
    aws_securityhub_account.this
  ]
}
#--------------------------------------------------------------
# Subscribes to a Security Hub standard.
# cis-aws-foundations-benchmark
#--------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "cis_aws_foundations_benchmark" {
  count         = var.is_enabled && var.enabled_cis_aws_foundations_benchmark ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on = [
    aws_securityhub_account.this
  ]
}
#--------------------------------------------------------------
# Subscribes to a Security Hub standard.
# pci-dss
#--------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "pci_dss" {
  count         = var.is_enabled && var.enabled_pci_dss ? 1 : 0
  standards_arn = "arn:aws:securityhub:${local.region}::standards/pci-dss/v/3.2.1"
  depends_on = [
    aws_securityhub_account.this
  ]
}
#--------------------------------------------------------------
# Creates Security Hub custom action.
#--------------------------------------------------------------
resource "aws_securityhub_action_target" "this" {
  count       = var.is_enabled ? 1 : 0
  name        = lookup(var.aws_securityhub_action_target, "name")
  identifier  = lookup(var.aws_securityhub_action_target, "identifier")
  description = lookup(var.aws_securityhub_action_target, "description")
  depends_on = [
    aws_securityhub_account.this
  ]
}

#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
# resource "aws_cloudwatch_event_rule" "this" {
#   count = var.is_enabled ? 1 : 0
#   name  = lookup(var.aws_cloudwatch_event_rule, "name", null)
#   # event_pattern: https://docs.aws.amazon.com/ja_jp/securityhub/latest/userguide/securityhub-cwe-event-formats.html
#   event_pattern = <<EVENT_PATTERN
# {
#   "source":[
#     "aws.securityhub"
#   ],
#   "detail-type":[
#     "Security Hub Findings - Imported"
#   ],
#   "detail":{
#     "findings":{
#       "Compliance":{
#         "Status":[
#           {
#             "anything-but":"PASSED"
#           }
#         ]
#       },
#       "Severity":{
#         "Label":[
#           "CRITICAL",
#           "HIGH"
#         ]
#       },
#       "Workflow":{
#         "Status":[
#           "NEW"
#         ]
#       },
#       "RecordState":[
#         "ACTIVE"
#       ]
#     }
#   }
# }
# EVENT_PATTERN
#   description   = lookup(var.aws_cloudwatch_event_rule, "description", null)
#   is_enabled    = true
#   tags          = var.tags
# }
#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
# resource "aws_cloudwatch_event_target" "this" {
#   count = var.is_enabled ? 1 : 0
#   rule  = aws_cloudwatch_event_rule.this[0].name
#   arn   = lookup(var.aws_cloudwatch_event_target, "arn", null)
#   depends_on = [
#     aws_cloudwatch_event_rule.this
#   ]
# }
