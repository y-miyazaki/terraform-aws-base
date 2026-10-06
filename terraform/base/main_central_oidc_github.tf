#--------------------------------------------------------------
# OpenID Connect for AWS and GitHub Actions
# Terraform module to configure GitHub Actions as an IAM OIDC identity provider in AWS.
# Allows GitHub Actions workflows to authenticate with AWS without storing long-lived credentials.
# The target ARN is output(oidc_github_iam_role_arn) for the target ARN.
# ex) oidc_github_iam_role_arn = "arn:aws:iam::{aws_account_id}:role/{iam_role_name}"
#
# SECURITY WARNING: dangerously_attach_admin_policy should be false in production!
# Use least privilege principles and attach only necessary policies.
#--------------------------------------------------------------
module "oidc_github" {
  for_each = var.oidc_github.settings
  source   = "unfunco/oidc-github/aws"
  version = "3.1.0"

  create               = var.oidc_github.is_enabled
  create_oidc_provider = each.value.create_oidc_provider

  dangerously_attach_admin_policy = each.value.dangerously_attach_admin_policy
  default_subject                 = "*"
  github_subjects                 = each.value.github_subjects
  iam_role_policy_names           = each.value.iam_role_policy_names
  iam_role_inline_policies = {
    format("%s%s%s%s", var.name_prefix, "oidc-github-", each.key, "-inline-policy") = jsonencode(each.value.iam_role_inline_policies)
  }
  iam_role_name = format("%s%s", var.name_prefix, each.value.iam_role_name)
  iam_role_path = each.value.iam_role_path

  tags = var.tags
}
