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
  for_each   = var.is_enabled ? var.securityhub_member : {}
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
  for_each    = var.is_enabled ? var.product_subscription : {}
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
