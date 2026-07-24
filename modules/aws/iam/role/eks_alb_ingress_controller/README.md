<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.0   |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 6.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                             | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.elb_service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                 | resource    |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                    | resource    |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                        | resource    |
| [aws_iam_role_policy_attachment.elb_service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                    | resource    |
| [aws_iam_policy_document.elb_service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                               | data source |

## Inputs

| Name                                                                                                                                  | Description                                                     | Type                                                                                                                                                                                                                                                                                                                                                                | Default                                                                                                                                                 | Required |
| ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input_aws_iam_policy)                                                         | (Optional) Provides an IAM policy.                              | <pre>object(<br/> {<br/> # Description of the IAM policy.<br/> description = optional(string)<br/> # The name of the policy. If omitted, Terraform will assign a random, unique name.<br/> name = string<br/> # Path in which to create the policy. See IAM Identifiers for more information.<br/> path = optional(string)<br/> }<br/> )</pre>                      | <pre>{<br/> "description": "IAM policy for EKS ALB ingress controller.",<br/> "name": "eks-alb-ingress-controller-policy",<br/> "path": "/"<br/>}</pre> |    no    |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input_aws_iam_role)                                                               | (Optional) Provides an IAM role.                                | <pre>object(<br/> {<br/> # Description of the role.<br/> description = optional(string)<br/> # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br/> name = string<br/> # Path to the role. See IAM Identifiers for more information.<br/> path = optional(string)<br/> }<br/> )</pre> | <pre>{<br/> "description": "IAM role for EKS ALB ingress controller.",<br/> "name": "eks-alb-ingress-controller-role",<br/> "path": "/"<br/>}</pre>     |    no    |
| <a name="input_cluster_identity_oidc_issuer_url"></a> [cluster\_identity\_oidc\_issuer\_url](#input_cluster_identity_oidc_issuer_url) | (Required) Issuer URL for the OpenID Connect identity provider. | `string`                                                                                                                                                                                                                                                                                                                                                            | n/a                                                                                                                                                     |   yes    |
| <a name="input_open_connect_provider_arn"></a> [open\_connect\_provider\_arn](#input_open_connect_provider_arn)                       | (Required) The ARN assigned by AWS for open connect provider.   | `string`                                                                                                                                                                                                                                                                                                                                                            | n/a                                                                                                                                                     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                         | (Optional) Key-value mapping of tags for the IAM role           | `map(any)`                                                                                                                                                                                                                                                                                                                                                          | `null`                                                                                                                                                  |    no    |

## Outputs

| Name                                         | Description                                     |
| -------------------------------------------- | ----------------------------------------------- |
| <a name="output_arn"></a> [arn](#output_arn) | Amazon Resource Name (ARN) specifying the role. |

<!-- END_TF_DOCS -->
