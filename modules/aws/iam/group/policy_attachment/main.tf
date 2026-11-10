#--------------------------------------------------------------
# Module: aws/iam/group/policy_attachment
# Purpose: Attach one or more managed IAM policies to IAM groups.
# Notes: Uses for_each keyed by group and policy ARN.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "this" {
  # Keyed by group and policy ARN so reordering the list does not recreate attachments.
  for_each = { for a in var.aws_iam_group_policy_attachment : "${a.group}/${a.policy_arn}" => a }

  group = each.value.group
  # example
  # policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
  policy_arn = each.value.policy_arn
}
