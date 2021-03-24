#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_iam_role" {
  type = object(
    {
      # (Optional) Description of the role.
      description = string
      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # (Optional) Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Required) Provides an IAM role."
  default = {
    description = null
    name        = "eks-alb-ingress-controller-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # (Optional, Forces new resource) Description of the IAM policy.
      description = string
      # (Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # (Optional, default "/") Path in which to create the policy. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Required) Provides an IAM policy."
  default = {
    description = null
    name        = "eks-alb-ingress-controller-policy"
    path        = "/"
  }
}
variable "open_connect_provider_arn" {
  type        = string
  description = "(Required) The ARN assigned by AWS for open connect provider."
  default     = null
}
variable "cluster_identity_oidc_issuer_url" {
  type        = string
  description = "(Required) Issuer URL for the OpenID Connect identity provider."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "Key-value mapping of tags for the IAM role"
  default     = null
}
