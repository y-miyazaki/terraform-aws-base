#--------------------------------------------------------------
# OpenID Connect for AWS and GitHub Actions
# Terraform module to configure GitHub Actions as an IAM OIDC identity provider in AWS.
# The target ARN is output(oidc_github_iam_role_arn) for the target ARN.
# ex) oidc_github_iam_role_arn = "arn:aws:iam::{aws_account_id}:role/{iam_role_name}"
#--------------------------------------------------------------
module "oidc_github" {
  source                  = "unfunco/oidc-github/aws"
  version                 = "1.8.1"
  attach_admin_policy     = var.oidc_github.attach_admin_policy
  attach_read_only_policy = var.oidc_github.attach_read_only_policy
  create_oidc_provider    = var.oidc_github.create_oidc_provider
  enabled                 = var.oidc_github.is_enabled
  github_repositories     = var.oidc_github.github_repositories
  iam_role_name           = format("%s%s", var.name_prefix, var.oidc_github.iam_role_name)
  iam_role_path           = var.oidc_github.iam_role_path
  tags                    = var.tags
}

output "oidc_github_iam_role_arn" {
  description = "IAM role arn for GitHub actions"
  value       = module.oidc_github.iam_role_arn
}
