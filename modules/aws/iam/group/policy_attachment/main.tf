#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "this" {
  count = length(var.aws_iam_group_policy_attachment)
  group = lookup(var.aws_iam_group_policy_attachment[count.index], "group")
  # exapmle
  # policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
  policy_arn = lookup(var.aws_iam_group_policy_attachment[count.index], "policy_arn")
}
