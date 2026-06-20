#--------------------------------------------------------------
# Module: aws/iam/role/ecs
# Purpose: Create IAM roles for ECS service, ECS task execution, and EventBridge run-task trigger with necessary policies and attachments.
# Notes: Unified tagging applied; future improvement: restrict wildcard permissions and parameterize managed policy ARNs; consider least-privilege for RunTask.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "ecs" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description           = try(var.aws_iam_role.ecs.description, null)
  force_detach_policies = true
  name                  = var.aws_iam_role.ecs.name
  path                  = try(var.aws_iam_role.ecs.path, "/")

  tags = var.tags
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
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "ecs_tasks" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description           = try(var.aws_iam_role.ecs_tasks.description, null)
  force_detach_policies = true
  name                  = var.aws_iam_role.ecs_tasks.name
  path                  = try(var.aws_iam_role.ecs_tasks.path, "/")

  tags = var.tags
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
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "events" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description           = try(var.aws_iam_role.events.description, null)
  force_detach_policies = true
  name                  = try(var.aws_iam_role.events.name)
  path                  = try(var.aws_iam_role.events.path, "/")

  tags = var.tags
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
  description = try(var.aws_iam_policy.events.description, null)
  name        = try(var.aws_iam_policy.events.name)
  path        = try(var.aws_iam_policy.events.path, "/")
  policy      = data.aws_iam_policy_document.this.json

  tags = var.tags
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
