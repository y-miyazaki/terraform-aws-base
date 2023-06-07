<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.eks_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.eks_worker_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_worker_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ec2_container_registry_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_worker_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_worker_node_external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.eks_worker_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_instance_profile"></a> [aws\_iam\_instance\_profile](#input\_aws\_iam\_instance\_profile) | (Optional) Provides an IAM instance profile. | <pre>object(<br>    {<br>      eks_worker_node = object({<br>        # Name of the instance profile. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix. Can be a string of characters consisting of upper and lowercase alphanumeric characters and these special characters: _, +, =, ,, ., @, -. Spaces are not allowed.<br>        name = string<br>        # Path to the instance profile. For more information about paths, see IAM Identifiers in the IAM User Guide. Can be a string of characters consisting of either a forward slash (/) by itself or a string that must begin and end with forward slashes. Can include any ASCII character from the ! (\u0021) through the DEL character (\u007F), including most punctuation characters, digits, and upper and lowercase letters.<br>        path = string<br>        }<br>      )<br>    }<br>  )</pre> | <pre>{<br>  "eks_worker_node": {<br>    "name": "eks-worker-node-profile",<br>    "path": "/"<br>  }<br>}</pre> | no |
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input\_aws\_iam\_policy) | (Optional) Provides an IAM policy. | <pre>object(<br>    {<br>      eks_worker_node = object({<br>        # Description of the IAM policy.<br>        description = string<br>        # The name of the policy. If omitted, Terraform will assign a random, unique name.<br>        name = string<br>        # Path in which to create the policy. See IAM Identifiers for more information.<br>        path = string<br>        }<br>      )<br>    }<br>  )</pre> | <pre>{<br>  "eks_worker_node": {<br>    "description": "Policy for EKS worker node.",<br>    "name": "eks-worker-node-policy",<br>    "path": "/"<br>  }<br>}</pre> | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) Provides an IAM role. | <pre>object(<br>    {<br>      eks = object({<br>        # Description of the role.<br>        description = string<br>        # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>        name = string<br>        # Path to the role. See IAM Identifiers for more information.<br>        path = string<br>        }<br>      )<br>      eks_worker_node = object({<br>        # Description of the role.<br>        description = string<br>        # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>        name = string<br>        # Path to the role. See IAM Identifiers for more information.<br>        path = string<br>        }<br>      )<br>    }<br>  )</pre> | <pre>{<br>  "eks": {<br>    "description": "Role for EKS.",<br>    "name": "eks-role",<br>    "path": "/"<br>  },<br>  "eks_worker_node": {<br>    "description": "Role for EKS worker node.",<br>    "name": "eks-worker-node-role",<br>    "path": "/"<br>  }<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value mapping of tags for the IAM role | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_arn"></a> [eks\_arn](#output\_eks\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_eks_name"></a> [eks\_name](#output\_eks\_name) | Name of the role. |
| <a name="output_node_arn"></a> [node\_arn](#output\_node\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_node_name"></a> [node\_name](#output\_node\_name) | Name of the role. |
<!-- END_TF_DOCS -->
