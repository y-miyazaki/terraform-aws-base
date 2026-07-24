<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.56.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_access_analyzer_organization"></a> [access\_analyzer\_organization](#module\_access\_analyzer\_organization) | ../../../modules/aws/security/access_analyzer | n/a |
| <a name="module_aws_chatbot_create"></a> [aws\_chatbot\_create](#module\_aws\_chatbot\_create) | ../../../modules/aws/chatbot/create | n/a |
| <a name="module_aws_chatbot_security_guardduty"></a> [aws\_chatbot\_security\_guardduty](#module\_aws\_chatbot\_security\_guardduty) | ../../../modules/aws/chatbot/security/guardduty | n/a |
| <a name="module_aws_chatbot_security_securityhub"></a> [aws\_chatbot\_security\_securityhub](#module\_aws\_chatbot\_security\_securityhub) | ../../../modules/aws/chatbot/security/securityhub | n/a |
| <a name="module_delegated_services"></a> [delegated\_services](#module\_delegated\_services) | ../../../modules/aws/organizations/delegated_services | n/a |
| <a name="module_guardduty_organization"></a> [guardduty\_organization](#module\_guardduty\_organization) | ../../../modules/aws/security/guardduty_organization | n/a |
| <a name="module_inspector2_organization"></a> [inspector2\_organization](#module\_inspector2\_organization) | ../../../modules/aws/security/inspector2_organization | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | terraform-aws-modules/kms/aws | 4.2.0 |
| <a name="module_macie_organization"></a> [macie\_organization](#module\_macie\_organization) | ../../../modules/aws/security/macie_organization | n/a |
| <a name="module_oidc_github"></a> [oidc\_github](#module\_oidc\_github) | unfunco/oidc-github/aws | 3.0.0 |
| <a name="module_securityhub_organization"></a> [securityhub\_organization](#module\_securityhub\_organization) | ../../../modules/aws/security/securityhub_organization | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_analyzer_organization"></a> [access\_analyzer\_organization](#input\_access\_analyzer\_organization) | n/a | <pre>object({<br/>    is_enabled    = bool<br/>    analyzer_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#input\_cloudwatch\_log\_group) | Common CloudWatch Log Group configuration for all services.<br/><br/>Priority order (higher priority overrides lower):<br/>1. var.cloudwatch\_log\_group.override.<service\_name>.retention\_in\_days (highest priority)<br/>2. var.cloudwatch\_log\_group.retention\_in\_days (lowest priority - common default)<br/><br/>Example:<br/>  cloudwatch\_log\_group = {<br/>    retention\_in\_days = 14  # Default for all services<br/>    override = {<br/>      security\_cloudtrail = {<br/>        retention\_in\_days = 90  # Override for security\_cloudtrail service<br/>      }<br/>    }<br/>  } | <pre>object({<br/>    retention_in_days = number<br/>    override = optional(object({<br/>      security_cloudtrail = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_guardduty_organization"></a> [guardduty\_organization](#input\_guardduty\_organization) | n/a | <pre>object({<br/>    is_enabled                       = bool<br/>    create_detector                  = optional(bool, false)<br/>    auto_enable_organization_members = optional(string, "ALL")<br/>    features = optional(map(object({<br/>      auto_enable = string<br/>      additional_configurations = optional(list(object({<br/>        name        = string<br/>        auto_enable = string<br/>      })), [])<br/>    })), {})<br/>  })</pre> | n/a | yes |
| <a name="input_inspector2_organization"></a> [inspector2\_organization](#input\_inspector2\_organization) | n/a | <pre>object({<br/>    is_enabled = bool<br/>    enabler = optional(map(object({<br/>      account_ids    = list(string)<br/>      resource_types = list(string)<br/>    })), {})<br/>    is_enabled_configuration = optional(bool, false)<br/>    configuration = optional(object({<br/>      auto_enable_ec2             = bool<br/>      auto_enable_ecr             = bool<br/>      auto_enable_lambda          = bool<br/>      auto_enable_lambda_code     = bool<br/>      auto_enable_code_repository = bool<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_kms"></a> [kms](#input\_kms) | n/a | <pre>map(object({<br/>    description             = string<br/>    deletion_window_in_days = number<br/>    is_enabled              = bool<br/>  }))</pre> | n/a | yes |
| <a name="input_macie_organization"></a> [macie\_organization](#input\_macie\_organization) | n/a | <pre>object({<br/>    is_enabled                   = bool<br/>    auto_enable                  = bool<br/>    status                       = string<br/>    finding_publishing_frequency = string<br/>    classification_jobs          = optional(any, [])<br/>    findings_filters             = optional(any, [])<br/>  })</pre> | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_oidc_github"></a> [oidc\_github](#input\_oidc\_github) | n/a | <pre>object({<br/>    is_enabled                      = bool<br/>    dangerously_attach_admin_policy = bool<br/>    iam_role_policy_names           = list(string)<br/>    create_oidc_provider            = bool<br/>    github_subjects                 = list(string)<br/>    iam_role_name                   = string<br/>    iam_role_path                   = string<br/>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region configuration for multi-region deployment | <pre>object({<br/>    global  = string<br/>    primary = string<br/>    targets = list(string)<br/>  })</pre> | n/a | yes |
| <a name="input_security_notification"></a> [security\_notification](#input\_security\_notification) | n/a | <pre>object({<br/>    slack_channel_id = string<br/>    slack_team_id    = string<br/>    guardduty = object({<br/>      is_enabled = bool<br/>    })<br/>    securityhub = object({<br/>      is_enabled = bool<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_securityhub_organization"></a> [securityhub\_organization](#input\_securityhub\_organization) | n/a | <pre>object({<br/>    is_enabled                    = bool<br/>    is_enabled_finding_aggregator = optional(bool, false)<br/>    configuration_policy = object({<br/>      service_enabled       = bool<br/>      name                  = optional(string)<br/>      enabled_standard_arns = optional(list(string), [])<br/>      security_controls_configuration = optional(object({<br/>        disabled_control_identifiers = optional(list(string), [])<br/>      }))<br/>    })<br/>    configuration_policy_name        = optional(string)<br/>    configuration_policy_description = optional(string, "")<br/>    linking_mode                     = optional(string, "ALL_REGIONS")<br/>    target_id                        = string<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_oidc_github_iam_role_arn"></a> [oidc\_github\_iam\_role\_arn](#output\_oidc\_github\_iam\_role\_arn) | IAM role arn for GitHub actions |
<!-- END_TF_DOCS -->
