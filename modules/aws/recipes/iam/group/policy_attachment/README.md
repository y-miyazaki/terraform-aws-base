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
| [aws_iam_group_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_group_policy_attachment"></a> [aws\_iam\_group\_policy\_attachment](#input\_aws\_iam\_group\_policy\_attachment) | (Required) - Attaches a Managed IAM Policy to an IAM group | <pre>list(object(<br>    {<br>      # The group the policy should be applied to<br>      group = string<br>      # The ARN of the policy you want to apply<br>      policy_arn = string<br>    }<br>    )<br>  )</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
