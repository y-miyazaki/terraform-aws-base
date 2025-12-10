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
  source  = "unfunco/oidc-github/aws"
  version = "2.0.2"
  create  = var.oidc_github.is_enabled

  dangerously_attach_admin_policy = var.oidc_github.dangerously_attach_admin_policy
  attach_read_only_policy         = var.oidc_github.attach_read_only_policy
  create_oidc_provider            = var.oidc_github.create_oidc_provider
  github_repositories             = var.oidc_github.github_repositories
  iam_role_name                   = format("%s%s", var.name_prefix, var.oidc_github.iam_role_name)
  iam_role_path                   = var.oidc_github.iam_role_path

  tags = var.tags
}

output "oidc_github_iam_role_arn" {
  description = "IAM role arn for GitHub actions"
  value       = module.oidc_github.iam_role_arn
}
