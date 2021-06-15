#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_iam_role" {
  type = object(
    {
      # Description of the role.
      description = string
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) Provides an IAM role."
  default = {
    description = "Role for EKS ALB ingress controller."
    name        = "eks-alb-ingress-controller-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = string
      # The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # Path in which to create the policy. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) Provides an IAM policy."
  default = {
    description = "Policy for EKS ALB ingress controller."
    name        = "eks-alb-ingress-controller-policy"
    path        = "/"
  }
}
variable "open_connect_provider_arn" {
  type        = string
  description = "(Required) The ARN assigned by AWS for open connect provider."
}
variable "cluster_identity_oidc_issuer_url" {
  type        = string
  description = "(Required) Issuer URL for the OpenID Connect identity provider."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value mapping of tags for the IAM role"
  default     = null
}
