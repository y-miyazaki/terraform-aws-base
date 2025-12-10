#--------------------------------------------------------------
# Module: aws/iam/group/policy_attachment
# Purpose: Attach one or more managed IAM policies to IAM groups.
# Notes: Uses count with list input; future improvement: switch to for_each keyed by group-policy for stability.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "this" {
  count = length(var.aws_iam_group_policy_attachment)

  group = var.aws_iam_group_policy_attachment[count.index].group
  # example
  # policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
  policy_arn = var.aws_iam_group_policy_attachment[count.index].policy_arn
}
