<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.56.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aws_budgets_create"></a> [aws\_budgets\_create](#module\_aws\_budgets\_create) | ../../modules/aws/budgets/create | n/a |
| <a name="module_aws_cloudwatch_alarm_cloudtrail"></a> [aws\_cloudwatch\_alarm\_cloudtrail](#module\_aws\_cloudwatch\_alarm\_cloudtrail) | ../../modules/aws/cloudwatch/alarm/log | n/a |
| <a name="module_aws_cloudwatch_events_guardduty"></a> [aws\_cloudwatch\_events\_guardduty](#module\_aws\_cloudwatch\_events\_guardduty) | ../../modules/aws/cloudwatch/events/guardduty | n/a |
| <a name="module_aws_cloudwatch_events_health"></a> [aws\_cloudwatch\_events\_health](#module\_aws\_cloudwatch\_events\_health) | ../../modules/aws/cloudwatch/events/health | n/a |
| <a name="module_aws_compute_optimizer"></a> [aws\_compute\_optimizer](#module\_aws\_compute\_optimizer) | ../../modules/aws/compute_optimizer | n/a |
| <a name="module_aws_iam_role_aws_support_app"></a> [aws\_iam\_role\_aws\_support\_app](#module\_aws\_iam\_role\_aws\_support\_app) | ../../modules/aws/iam/role/aws_support_app | n/a |
| <a name="module_aws_iam_role_eventbridge"></a> [aws\_iam\_role\_eventbridge](#module\_aws\_iam\_role\_eventbridge) | ../../modules/aws/iam/role/eventbridge | n/a |
| <a name="module_aws_iam_role_lambda"></a> [aws\_iam\_role\_lambda](#module\_aws\_iam\_role\_lambda) | ../../modules/aws/iam/role/lambda | n/a |
| <a name="module_aws_iam_switch_role_from"></a> [aws\_iam\_switch\_role\_from](#module\_aws\_iam\_switch\_role\_from) | ../../modules/aws/iam/switch_role/from | n/a |
| <a name="module_aws_iam_switch_role_to"></a> [aws\_iam\_switch\_role\_to](#module\_aws\_iam\_switch\_role\_to) | ../../modules/aws/iam/switch_role/to | n/a |
| <a name="module_aws_iam_user_group"></a> [aws\_iam\_user\_group](#module\_aws\_iam\_user\_group) | ../../modules/aws/iam/user_group | n/a |
| <a name="module_aws_resourcegroups_group"></a> [aws\_resourcegroups\_group](#module\_aws\_resourcegroups\_group) | ../../modules/aws/resource_groups | n/a |
| <a name="module_aws_s3_policy_config_log"></a> [aws\_s3\_policy\_config\_log](#module\_aws\_s3\_policy\_config\_log) | ../../modules/aws/s3/bucket_policy/config | n/a |
| <a name="module_aws_s3_policy_redshift_log"></a> [aws\_s3\_policy\_redshift\_log](#module\_aws\_s3\_policy\_redshift\_log) | ../../modules/aws/s3/bucket_policy/redshift | n/a |
| <a name="module_aws_security_access_analyzer"></a> [aws\_security\_access\_analyzer](#module\_aws\_security\_access\_analyzer) | ../../modules/aws/security/access_analyzer | n/a |
| <a name="module_aws_security_athena"></a> [aws\_security\_athena](#module\_aws\_security\_athena) | ../../modules/aws/security/athena | n/a |
| <a name="module_aws_security_cloudtrail"></a> [aws\_security\_cloudtrail](#module\_aws\_security\_cloudtrail) | ../../modules/aws/security/cloudtrail/cloudtrail | n/a |
| <a name="module_aws_security_config_create"></a> [aws\_security\_config\_create](#module\_aws\_security\_config\_create) | ../../modules/aws/security/config/create | n/a |
| <a name="module_aws_security_config_rule_s3"></a> [aws\_security\_config\_rule\_s3](#module\_aws\_security\_config\_rule\_s3) | ../../modules/aws/security/config/rule/s3 | n/a |
| <a name="module_aws_security_default_vpc"></a> [aws\_security\_default\_vpc](#module\_aws\_security\_default\_vpc) | ../../modules/aws/security/default_vpc | n/a |
| <a name="module_aws_security_ebs"></a> [aws\_security\_ebs](#module\_aws\_security\_ebs) | ../../modules/aws/security/ebs | n/a |
| <a name="module_aws_security_ec2_metadata"></a> [aws\_security\_ec2\_metadata](#module\_aws\_security\_ec2\_metadata) | ../../modules/aws/security/ec2_metadata | n/a |
| <a name="module_aws_security_ecr"></a> [aws\_security\_ecr](#module\_aws\_security\_ecr) | ../../modules/aws/security/ecr | n/a |
| <a name="module_aws_security_iam"></a> [aws\_security\_iam](#module\_aws\_security\_iam) | ../../modules/aws/security/iam | n/a |
| <a name="module_aws_security_inspector2"></a> [aws\_security\_inspector2](#module\_aws\_security\_inspector2) | ../../modules/aws/security/inspector2 | n/a |
| <a name="module_aws_security_macie"></a> [aws\_security\_macie](#module\_aws\_security\_macie) | ../../modules/aws/security/macie | n/a |
| <a name="module_aws_security_securityhub"></a> [aws\_security\_securityhub](#module\_aws\_security\_securityhub) | ../../modules/aws/security/securityhub | n/a |
| <a name="module_aws_security_ssm_automation"></a> [aws\_security\_ssm\_automation](#module\_aws\_security\_ssm\_automation) | ../../modules/aws/security/ssm_automation | n/a |
| <a name="module_guardduty"></a> [guardduty](#module\_guardduty) | ../../modules/aws/security/guardduty | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | terraform-aws-modules/kms/aws | 4.2.0 |
| <a name="module_lambda_function_budgets"></a> [lambda\_function\_budgets](#module\_lambda\_function\_budgets) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_lambda_function_cloudtrail"></a> [lambda\_function\_cloudtrail](#module\_lambda\_function\_cloudtrail) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_lambda_function_iam_password_expired"></a> [lambda\_function\_iam\_password\_expired](#module\_lambda\_function\_iam\_password\_expired) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_lambda_function_trusted_advisor"></a> [lambda\_function\_trusted\_advisor](#module\_lambda\_function\_trusted\_advisor) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_lambda_vpc"></a> [lambda\_vpc](#module\_lambda\_vpc) | terraform-aws-modules/vpc/aws | 6.6.1 |
| <a name="module_oidc_github"></a> [oidc\_github](#module\_oidc\_github) | unfunco/oidc-github/aws | 3.0.0 |
| <a name="module_s3_account_public_access"></a> [s3\_account\_public\_access](#module\_s3\_account\_public\_access) | terraform-aws-modules/s3-bucket/aws//modules/account-public-access | 5.14.1 |
| <a name="module_s3_cloudtrail"></a> [s3\_cloudtrail](#module\_s3\_cloudtrail) | terraform-aws-modules/s3-bucket/aws | 5.14.1 |
| <a name="module_s3_log"></a> [s3\_log](#module\_s3\_log) | terraform-aws-modules/s3-bucket/aws | 5.14.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_scheduler_schedule.budgets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.iam_password_expired](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.trusted_advisor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_availability_zones.lambda_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_cloudfront_log_delivery_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_log_delivery_canonical_user_id) | data source |
| [aws_iam_policy_document.s3_log_combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_budgets"></a> [budgets](#input\_budgets) | n/a | `any` | n/a | yes |
| <a name="input_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#input\_cloudwatch\_log\_group) | Common CloudWatch Log Group configuration for all services.<br/><br/>Priority order (higher priority overrides lower):<br/>1. var.cloudwatch\_log\_group.override.<service\_name>.retention\_in\_days (highest priority)<br/>2. var.cloudwatch\_log\_group.retention\_in\_days (lowest priority - common default)<br/><br/>Example:<br/>  cloudwatch\_log\_group = {<br/>    retention\_in\_days = 14  # Default for all services<br/>    override = {<br/>      budgets = {<br/>        retention\_in\_days = 7  # Override for budgets service<br/>      }<br/>      security\_cloudtrail = {<br/>        retention\_in\_days = 90  # Override for security\_cloudtrail service<br/>      }<br/>    }<br/>  } | <pre>object({<br/>    retention_in_days = number<br/>    override = optional(object({<br/>      budgets = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      common_lambda_vpc_flow_log = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      guardduty = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      health = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      iam_password_expired = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      security_cloudtrail = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      security_config = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      security_securityhub = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      security_ssm_automation = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      trusted_advisor = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_common_lambda"></a> [common\_lambda](#input\_common\_lambda) | n/a | `any` | n/a | yes |
| <a name="input_common_log"></a> [common\_log](#input\_common\_log) | n/a | `any` | n/a | yes |
| <a name="input_compute_optimizer"></a> [compute\_optimizer](#input\_compute\_optimizer) | n/a | `any` | n/a | yes |
| <a name="input_control_tower"></a> [control\_tower](#input\_control\_tower) | Control Tower and organization-managed security services configuration.<br/><br/>Use this object to describe whether Control Tower is enabled and which<br/>services are centrally managed outside this base stack.<br/><br/>When managed\_services.<service> is omitted, it falls back to is\_enabled. | <pre>object({<br/>    is_enabled = bool<br/>    managed_services = optional(object({<br/>      access_analyzer = optional(bool)<br/>      cloudtrail      = optional(bool)<br/>      config          = optional(bool)<br/>      guardduty       = optional(bool)<br/>      inspector2      = optional(bool)<br/>      macie           = optional(bool)<br/>      securityhub     = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_guardduty"></a> [guardduty](#input\_guardduty) | n/a | `any` | n/a | yes |
| <a name="input_health"></a> [health](#input\_health) | n/a | `any` | n/a | yes |
| <a name="input_iam"></a> [iam](#input\_iam) | n/a | `any` | n/a | yes |
| <a name="input_iam_password_expired"></a> [iam\_password\_expired](#input\_iam\_password\_expired) | n/a | `any` | n/a | yes |
| <a name="input_kms"></a> [kms](#input\_kms) | n/a | `any` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_oidc_github"></a> [oidc\_github](#input\_oidc\_github) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region configuration for multi-region deployment | <pre>object({<br/>    global  = string<br/>    primary = string<br/>    targets = list(string)<br/>  })</pre> | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | n/a | `any` | n/a | yes |
| <a name="input_security_access_analyzer"></a> [security\_access\_analyzer](#input\_security\_access\_analyzer) | security | `any` | n/a | yes |
| <a name="input_security_athena"></a> [security\_athena](#input\_security\_athena) | n/a | `any` | n/a | yes |
| <a name="input_security_cloudtrail"></a> [security\_cloudtrail](#input\_security\_cloudtrail) | n/a | `any` | n/a | yes |
| <a name="input_security_config"></a> [security\_config](#input\_security\_config) | n/a | `any` | n/a | yes |
| <a name="input_security_default_vpc"></a> [security\_default\_vpc](#input\_security\_default\_vpc) | n/a | `any` | n/a | yes |
| <a name="input_security_ebs"></a> [security\_ebs](#input\_security\_ebs) | n/a | `any` | n/a | yes |
| <a name="input_security_ec2_metadata"></a> [security\_ec2\_metadata](#input\_security\_ec2\_metadata) | n/a | <pre>object({<br/>    is_enabled = bool<br/>  })</pre> | n/a | yes |
| <a name="input_security_ecr"></a> [security\_ecr](#input\_security\_ecr) | n/a | <pre>object({<br/>    is_enabled = bool<br/>  })</pre> | n/a | yes |
| <a name="input_security_guardduty"></a> [security\_guardduty](#input\_security\_guardduty) | n/a | `any` | n/a | yes |
| <a name="input_security_iam"></a> [security\_iam](#input\_security\_iam) | n/a | `any` | n/a | yes |
| <a name="input_security_inspector2"></a> [security\_inspector2](#input\_security\_inspector2) | n/a | `any` | n/a | yes |
| <a name="input_security_macie"></a> [security\_macie](#input\_security\_macie) | n/a | `any` | n/a | yes |
| <a name="input_security_s3"></a> [security\_s3](#input\_security\_s3) | n/a | `any` | n/a | yes |
| <a name="input_security_securityhub"></a> [security\_securityhub](#input\_security\_securityhub) | n/a | `any` | n/a | yes |
| <a name="input_security_ssm_automation"></a> [security\_ssm\_automation](#input\_security\_ssm\_automation) | n/a | `any` | n/a | yes |
| <a name="input_slack"></a> [slack](#input\_slack) | Common Slack configuration for all Lambda functions.<br/><br/>Priority order (higher priority overrides lower):<br/>1. var.slack.override.<function\_name> (highest priority)<br/>2. var.<function\_name>.aws\_lambda\_function.environment.SLACK\_* (middle priority)<br/>3. var.slack (lowest priority - common defaults)<br/><br/>Example:<br/>  slack = {<br/>    oauth\_access\_token = "xoxb-common-token"<br/>    channel\_id         = "C-common-channel"<br/>    override = {<br/>      budgets = {<br/>        channel\_id = "C-budgets-specific-channel"  # Override only channel\_id for budgets<br/>      }<br/>      guardduty = {<br/>        oauth\_access\_token = "xoxb-guardduty-token"  # Override token for guardduty<br/>        channel\_id         = "C-guardduty-channel"   # Override channel for guardduty<br/>      }<br/>    }<br/>  } | <pre>object({<br/>    oauth_access_token = string<br/>    channel_id         = string<br/>    override = optional(object({<br/>      budgets = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      guardduty = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      health = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      trusted_advisor = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      iam_password_expired = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      security_cloudtrail = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      security_config = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_trusted_advisor"></a> [trusted\_advisor](#input\_trusted\_advisor) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_iam_access_key"></a> [iam\_access\_key](#output\_iam\_access\_key) | n/a |
| <a name="output_iam_user_login_profile"></a> [iam\_user\_login\_profile](#output\_iam\_user\_login\_profile) | -------------------------------------------------------------- Output -------------------------------------------------------------- |
| <a name="output_lambda_vpc_default_security_group_id"></a> [lambda\_vpc\_default\_security\_group\_id](#output\_lambda\_vpc\_default\_security\_group\_id) | The ID of the default security group for Lambda VPC |
| <a name="output_lambda_vpc_id"></a> [lambda\_vpc\_id](#output\_lambda\_vpc\_id) | The ID of the VPC created for Lambda functions |
| <a name="output_lambda_vpc_private_subnet"></a> [lambda\_vpc\_private\_subnet](#output\_lambda\_vpc\_private\_subnet) | List of private subnet IDs where Lambda functions will be deployed |
| <a name="output_oidc_github_iam_role_arn"></a> [oidc\_github\_iam\_role\_arn](#output\_oidc\_github\_iam\_role\_arn) | IAM role arn for GitHub actions |
<!-- END_TF_DOCS -->
