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
# Provides an IAM role.
# role: eks.amazonaws.com
#--------------------------------------------------------------
resource "aws_iam_role" "eks" {
  description           = lookup(var.aws_iam_role.eks, "description", null)
  name                  = lookup(var.aws_iam_role.eks, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role.eks, "path", "/")
  tags                  = local.tags
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# AmazonEKSClusterPolicy
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# AmazonEKSServicePolicy
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks.name
}
#--------------------------------------------------------------
# Provides an IAM role.
# role: eks.amazonaws.com
#--------------------------------------------------------------
resource "aws_iam_role" "eks_worker_node" {
  description           = lookup(var.aws_iam_role.eks_worker_node, "description", null)
  name                  = lookup(var.aws_iam_role.eks_worker_node, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role.eks_worker_node, "path", "/")
  tags                  = local.tags
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# AmazonEKSWorkerNodePolicy
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_node.name
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# AmazonEKS_CNI_Policy
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_node.name
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
# AmazonEC2ContainerRegistryReadOnly
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_node.name
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "eks_worker_node" {
  # policy attach: for worker node cluster autoscaling
  # - Cluster Autoscaler
  #   https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/cluster-autoscaler.html
  statement {
    sid    = "AllowWorkerNodeClusterAutoScaling"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowExternalDNS1"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }
  statement {
    sid    = "AllowExternalDNS2"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "*"
    ]
  }
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
resource "aws_iam_policy" "eks_worker_node" {
  description = lookup(var.aws_iam_policy.eks_worker_node, "description", null)
  name        = lookup(var.aws_iam_policy.eks_worker_node, "name")
  path        = lookup(var.aws_iam_policy.eks_worker_node, "path", "/")
  policy      = data.aws_iam_policy_document.eks_worker_node.json
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_worker_node_external_dns" {
  policy_arn = aws_iam_policy.eks_worker_node.arn
  role       = aws_iam_role.eks_worker_node.name
}

#--------------------------------------------------------------
# Provides an IAM instance profile.
#--------------------------------------------------------------
resource "aws_iam_instance_profile" "eks_node" {
  name = lookup(var.aws_iam_instance_profile.eks_worker_node, "name")
  path = lookup(var.aws_iam_instance_profile.eks_worker_node, "path", "/")
  role = aws_iam_role.eks_worker_node.name
}
