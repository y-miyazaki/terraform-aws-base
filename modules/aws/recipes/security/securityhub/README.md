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
| [aws_securityhub_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_action_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_action_target) | resource |
| [aws_securityhub_member.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_member) | resource |
| [aws_securityhub_product_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_product_subscription) | resource |
| [aws_securityhub_standards_subscription.cis_aws_foundations_benchmark](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.pci_dss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_securityhub_action_target"></a> [aws\_securityhub\_action\_target](#input\_aws\_securityhub\_action\_target) | (Optional) Creates Security Hub custom action. | <pre>object({<br>    name        = string<br>    identifier  = string<br>    description = string<br>  })</pre> | <pre>{<br>  "description": "This is custom action sends selected findings to event",<br>  "identifier": "SendToEvent",<br>  "name": "Send notification"<br>}</pre> | no |
| <a name="input_aws_securityhub_member"></a> [aws\_securityhub\_member](#input\_aws\_securityhub\_member) | (Optional) list of Security Hub member resource. | `map(any)` | `null` | no |
| <a name="input_aws_securityhub_product_subscription"></a> [aws\_securityhub\_product\_subscription](#input\_aws\_securityhub\_product\_subscription) | (Optional) The ARN of the product that generates findings that you want to import into Security Hub - see below. | `map(any)` | `null` | no |
| <a name="input_cis_aws_foundations_benchmark_version"></a> [cis\_aws\_foundations\_benchmark\_version](#input\_cis\_aws\_foundations\_benchmark\_version) | (Optional) CIS AWS Foundations Benchmark version. Please check https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-cis1.4-vs-cis1.2.html | `string` | `"1.4.0"` | no |
| <a name="input_enabled_cis_aws_foundations_benchmark"></a> [enabled\_cis\_aws\_foundations\_benchmark](#input\_enabled\_cis\_aws\_foundations\_benchmark) | (Optional) CIS AWS Foundations Benchmark is valid, set it to true. default is true. | `bool` | `true` | no |
| <a name="input_enabled_pci_dss"></a> [enabled\_pci\_dss](#input\_enabled\_pci\_dss) | (Optional) PCI DSS is valid, set it to true. default is true. | `bool` | `true` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable SecurityHub. Defaults true. | `bool` | `true` | no |
| <a name="input_pci_dss_version"></a> [pci\_dss\_version](#input\_pci\_dss\_version) | (Optional) PCI DSS version. Please check https://aws.amazon.com/compliance/pci-dss-level-1-faqs/ | `string` | `"3.2.1"` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region name. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
