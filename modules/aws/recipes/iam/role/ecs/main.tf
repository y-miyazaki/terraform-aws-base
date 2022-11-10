#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# role: ecs.amazonaws.com
#--------------------------------------------------------------
resource "aws_iam_role" "ecs" {
  description           = lookup(var.aws_iam_role.ecs, "description", null)
  name                  = lookup(var.aws_iam_role.ecs, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role.ecs, "path", "/")
  tags                  = local.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# policy attach: AmazonEC2ContainerServiceRole
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

#--------------------------------------------------------------
# role: ecs-tasks.amazonaws.com
# https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task_execution_IAM_role.html
#--------------------------------------------------------------
resource "aws_iam_role" "ecs_tasks" {
  description           = lookup(var.aws_iam_role.ecs_tasks, "description", null)
  name                  = lookup(var.aws_iam_role.ecs_tasks, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role.ecs_tasks, "path", "/")
  tags                  = local.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# policy attach: AmazonECSTaskExecutionRolePolicy
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs_tasks" {
  role       = aws_iam_role.ecs_tasks.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#--------------------------------------------------------------
# events.amazonaws.com
#--------------------------------------------------------------
resource "aws_iam_role" "events" {
  description           = lookup(var.aws_iam_role.events, "description", null)
  name                  = lookup(var.aws_iam_role.events, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role.events, "path", "/")
  tags                  = local.tags
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.ecs_tasks.arn,
    ]
  }
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
resource "aws_iam_policy" "events" {
  description = lookup(var.aws_iam_policy.events, "description", null)
  name        = lookup(var.aws_iam_policy.events, "name")
  path        = lookup(var.aws_iam_policy.events, "path", "/")
  policy      = data.aws_iam_policy_document.this.json
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# policy attach: ECS runtask
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "events" {
  role       = aws_iam_role.events.name
  policy_arn = aws_iam_policy.events.arn
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# events.amazonaws.com role adds CloudWatchLogsFullAccess policy
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.events.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
