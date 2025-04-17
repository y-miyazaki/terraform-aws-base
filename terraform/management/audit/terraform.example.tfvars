#--------------------------------------------------------------
# Default Tags for Resources
# A tag that is set globally for the resources used.
#--------------------------------------------------------------
# TODO: need to change tags.
tags = {
  # TODO: need to change env.
  env = "example"
  # TODO: need to change service.
  # service is project name or job name or product name.
  service = "base"
  # Map Program
  # map-migrated = "xxxxxxxxxxxxx"
}
#--------------------------------------------------------------
# Name prefix
# It is used as a prefix attached to various resource names.
#--------------------------------------------------------------
name_prefix = "base-"
#--------------------------------------------------------------
# CloudWatch Logs retention in days
#--------------------------------------------------------------
# TODO: need to change CloudWatch Logs retention in days.
cloudwatch_log_group_retention_in_days = 14
#--------------------------------------------------------------
# OpenID Connect for AWS and GitHub Actions
# Terraform module to configure GitHub Actions as an IAM OIDC identity provider in AWS.
# The target ARN is output(oidc_github_iam_role_arn) for the target ARN.
# ex) oidc_github_iam_role_arn = "arn:aws:iam::{aws_account_id}:role/{iam_role_name}"
#--------------------------------------------------------------
oidc_github = {
  # TODO: need to set is_enabled for settings of IAM OIDC for GitHub Actions.
  is_enabled = true
  # TODO: Flag to enable/disable the attachment of the AdministratorAccess policy.
  attach_admin_policy = true
  # TODO: Flag to enable/disable the attachment of the ReadOnly policy.
  attach_read_only_policy = false
  # TODO: Flag to enable/disable the creation of the GitHub OIDC provider.
  create_oidc_provider = true
  # TODO: Set the org/repo of the GitHub repository to github_repositories.
  github_repositories = [
    # "your-repository/repository-name",
  ]
  iam_role_name = "oidc-github-role"
  iam_role_path = "/"
}
#--------------------------------------------------------------
# Security
#--------------------------------------------------------------
security = {
  #--------------------------------------------------------------
  # Security:SecurityHub
  #--------------------------------------------------------------
  # TODO: need to set slack_channel_id for settings of AWS SecurityHub.
  slack_channel_id = "xxxxxxxxxxx"
  # TODO: need to set slack_workspace_id for settings of AWS SecurityHub.
  slack_workspace_id = "xxxxxxxxxxx"
  securityhub = {
    # TODO: need to set is_enabled for settings of SecurityHub.
    is_enabled = true
  }
  #--------------------------------------------------------------
  # GuardDuty
  # Amazon GuardDuty is a threat detection service that continuously monitors your AWS accounts and workloads for malicious activity and
  # delivers detailed security findings for visibility and remediation.
  #--------------------------------------------------------------
  guardduty = {
    # TODO: need to set is_enabled for settings of AWS GuardDuty.
    is_enabled = true
  }
}
