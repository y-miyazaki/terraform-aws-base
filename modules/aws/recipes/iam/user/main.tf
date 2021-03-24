#--------------------------------------------------------------
# Provides an IAM user.
#--------------------------------------------------------------
resource "aws_iam_user" "this" {
  for_each = toset(var.iam_user_users)
  name     = each.value
  path     = "/"
}
#--------------------------------------------------------------
# Manages an IAM User Login Profile with limited support for password creation during Terraform resource creation. Uses PGP to encrypt the password for safe transport to the user. PGP keys can be obtained from Keybase.
#--------------------------------------------------------------
resource "aws_iam_user_login_profile" "this" {
  for_each                = toset(var.iam_user_users)
  user                    = each.value
  pgp_key                 = "keybase:exp_enechange"
  password_reset_required = true
  password_length         = "20"
  depends_on = [
    aws_iam_user.this,
  ]
}
#--------------------------------------------------------------
# IAM Group for administrator
#--------------------------------------------------------------
resource "aws_iam_group" "administrator" {
  name = "administrator"
  path = "/"
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "administrator" {
  group      = aws_iam_group.administrator.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#--------------------------------------------------------------
# IAM Group for developer
#--------------------------------------------------------------
resource "aws_iam_group" "developer" {
  name = "developer"
  path = "/"
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
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
        "arn:aws:iam::*:mfa/$${aws:username}",
        "arn:aws:iam::*:user/$${aws:username}"
      ]
    },
    {
      "Sid": "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA",
      "Effect": "Allow",
      "Action": ["iam:DeactivateMFADevice"],
      "Resource": [
        "arn:aws:iam::*:mfa/$${aws:username}",
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
resource "aws_iam_group_policy_attachment" "developer" {
  group      = aws_iam_group.developer.name
  policy_arn = aws_iam_policy.this.arn
}

#--------------------------------------------------------------
# IAM Group for operator
#--------------------------------------------------------------
resource "aws_iam_group" "operator" {
  name = "operator"
  path = "/"
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "operator" {
  group      = aws_iam_group.operator.name
  policy_arn = aws_iam_policy.this.arn
}
#--------------------------------------------------------------
# IAM Group Mapping
#--------------------------------------------------------------
resource "aws_iam_group_membership" "administrator" {
  name  = "administrator-membership"
  users = var.iam_user_group_administrator
  group = "administrator"

  depends_on = [
    aws_iam_group.administrator,
    aws_iam_user.this,
  ]
}

resource "aws_iam_group_membership" "developer" {
  name  = "developer-membership"
  users = var.iam_user_group_developer
  group = "developer"

  depends_on = [
    aws_iam_group.developer,
    aws_iam_user.this,
  ]
}

resource "aws_iam_group_membership" "operator" {
  name  = "operator-membership"
  users = var.iam_user_group_operator
  group = "operator"

  depends_on = [
    aws_iam_group.operator,
    aws_iam_user.this,
  ]
}
