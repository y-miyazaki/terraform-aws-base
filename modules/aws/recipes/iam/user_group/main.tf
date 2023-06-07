#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  group = flatten([
    for group, group_property in var.group : {
      group           = group
      users           = group_property.users
      policy_document = group_property.policy_document
      is_enabled_mfa  = group_property.is_enabled_mfa
    }
    ]
  )
  group_policy_arns = flatten([
    for group, group_property in var.group : [
      for key, policy in group_property.policy : {
        group      = group
        policy_arn = policy.policy_arn
        key        = key
      }
    ]
  ])
}
#--------------------------------------------------------------
# Provides an IAM user.
#--------------------------------------------------------------
resource "aws_iam_user" "this" {
  for_each      = var.user
  name          = each.key
  path          = "/"
  force_destroy = true
}
#--------------------------------------------------------------
# Manages an IAM User Login Profile with limited support for password creation during Terraform resource creation. Uses PGP to encrypt the password for safe transport to the user. PGP keys can be obtained from Keybase.
#--------------------------------------------------------------
resource "aws_iam_user_login_profile" "this" {
  for_each                = { for k, v in var.user : k => v if v.is_console_access }
  user                    = each.key
  pgp_key                 = "keybase:exp_enechange"
  password_reset_required = true
  # Check this following document.
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile#import
  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
  depends_on = [
    aws_iam_user.this,
  ]
}
#--------------------------------------------------------------
# IAM Group for administrator
#--------------------------------------------------------------
resource "aws_iam_group" "this" {
  for_each = {
    for group in local.group : group.group => group
  }
  name = each.value.group
  path = "/"
}
#--------------------------------------------------------------
# IAM Group Mapping
#--------------------------------------------------------------
resource "aws_iam_group_membership" "this" {
  for_each = {
    for group in local.group : group.group => group
  }
  name  = "${each.key}-membership"
  users = each.value.users
  group = each.value.group

  depends_on = [
    aws_iam_group.this,
    aws_iam_user.this,
  ]
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
resource "aws_iam_policy" "this" {
  name   = "${var.name_prefix}iam-group-base-policy"
  path   = "/"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAllUsersToListAccounts",
      "Effect": "Allow",
      "Action": [
        "iam:ListAccountAliases",
        "iam:ListUsers",
        "iam:ListVirtualMFADevices",
        "iam:GetAccountPasswordPolicy",
        "iam:GetAccountSummary"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation",
      "Effect": "Allow",
      "Action": [
        "iam:ChangePassword",
        "iam:CreateAccessKey",
        "iam:CreateLoginProfile",
        "iam:DeleteAccessKey",
        "iam:DeleteLoginProfile",
        "iam:GetLoginProfile",
        "iam:ListAccessKeys",
        "iam:UpdateAccessKey",
        "iam:UpdateLoginProfile",
        "iam:ListSigningCertificates",
        "iam:DeleteSigningCertificate",
        "iam:UpdateSigningCertificate",
        "iam:UploadSigningCertificate",
        "iam:ListSSHPublicKeys",
        "iam:GetSSHPublicKey",
        "iam:DeleteSSHPublicKey",
        "iam:UpdateSSHPublicKey",
        "iam:UploadSSHPublicKey"
      ],
      "Resource": "arn:aws:iam::*:user/$${aws:username}"
    },
    {
      "Sid": "AllowIndividualUserToListOnlyTheirOwnMFA",
      "Effect": "Allow",
      "Action": ["iam:ListMFADevices"],
      "Resource": [
        "arn:aws:iam::*:mfa/*",
        "arn:aws:iam::*:user/$${aws:username}"
      ]
    },
    {
      "Sid": "AllowIndividualUserToManageTheirOwnMFA",
      "Effect": "Allow",
      "Action": [
        "iam:CreateVirtualMFADevice",
        "iam:DeleteVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:ResyncMFADevice"
      ],
      "Resource": [
        "arn:aws:iam::*:mfa/*",
        "arn:aws:iam::*:user/$${aws:username}"
      ]
    },
    {
      "Sid": "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA",
      "Effect": "Allow",
      "Action": ["iam:DeactivateMFADevice"],
      "Resource": [
        "arn:aws:iam::*:mfa/*",
        "arn:aws:iam::*:user/$${aws:username}"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    },
    {
      "Sid": "BlockMostAccessUnlessSignedInWithMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:DeleteVirtualMFADevice",
        "iam:ListVirtualMFADevices",
        "iam:EnableMFADevice",
        "iam:ResyncMFADevice",
        "iam:ListAccountAliases",
        "iam:ListUsers",
        "iam:ListSSHPublicKeys",
        "iam:ListAccessKeys",
        "iam:ListServiceSpecificCredentials",
        "iam:ListMFADevices",
        "iam:GetAccountSummary",
        "sts:GetSessionToken",
        "iam:CreateLoginProfile",
        "iam:ChangePassword"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
POLICY
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "mfa" {
  for_each = {
    for group in local.group : group.group => group if(lookup(group, "is_enabled_mfa", true))
  }
  group      = each.value.group
  policy_arn = aws_iam_policy.this.arn
  depends_on = [
    aws_iam_group.this,
    aws_iam_policy.this,
  ]
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "this" {
  for_each = {
    for tm in local.group_policy_arns : "${tm.group}-${tm.key}" => tm
  }
  group      = each.value.group
  policy_arn = each.value.policy_arn
  depends_on = [
    aws_iam_group.this,
  ]
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "custom" {
  for_each = {
    for group in local.group : group.group => group if(group.policy_document != null)
  }
  dynamic "statement" {
    for_each = lookup(each.value.policy_document, "statement", [])
    content {
      sid           = lookup(statement.value, "sid", null)
      effect        = lookup(statement.value, "effect", null)
      actions       = lookup(statement.value, "actions", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)
      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          type        = lookup(principals.value, "type", null)
          identifiers = lookup(principals.value, "identifiers", null)
        }
      }
      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", [])
        content {
          type        = lookup(not_principals.value, "type", null)
          identifiers = lookup(not_principals.value, "identifiers", null)
        }
      }
      dynamic "condition" {
        for_each = lookup(statement.value, "condition", [])
        content {
          test     = lookup(condition.value, "test", null)
          variable = lookup(condition.value, "variable", null)
          values   = lookup(condition.value, "values", null)
        }
      }
    }
  }
}
#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "custom" {
  for_each = {
    for group in local.group : group.group => group if(group.policy_document != null)
  }
  description = lookup(each.value.policy_document, "description", null)
  name        = "${var.name_prefix}${lookup(each.value.policy_document, "name", null)}"
  #   name_prefix = var.name_prefix
  path   = lookup(each.value.policy_document, "path", "/")
  policy = data.aws_iam_policy_document.custom[each.key].json
  depends_on = [
    aws_iam_group.this,
  ]
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "custom" {
  for_each = {
    for group in local.group : group.group => group if(group.policy_document != null)
  }
  group      = each.value.group
  policy_arn = aws_iam_policy.custom[each.key].arn
  depends_on = [
    aws_iam_group.this,
  ]
}
#--------------------------------------------------------------
# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
#--------------------------------------------------------------
resource "aws_iam_access_key" "this" {
  for_each = { for k, v in var.user : k => v if v.is_access_key }
  user     = each.key
}
