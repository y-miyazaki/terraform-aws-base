# cloudtrail_filter_pattern

Internal helper that builds the CloudWatch.2 (unauthorized API calls) and CloudWatch.4 (IAM policy changes) CloudTrail metric filter patterns, including event exclusions. Used by `security/cloudtrail/cloudtrail` and `security/cloudtrail/controltower`; not intended for direct use.

- Pure computation, no resources.
- Output patterns have no trailing newline; callers append it where the metric filter needs one.
- Validation of the exclusion inputs stays with the caller.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0, < 7.0.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloudwatch_2_event_exclusions"></a> [cloudwatch\_2\_event\_exclusions](#input\_cloudwatch\_2\_event\_exclusions) | (Optional) Exclusions from CloudWatch.2 unauthorized API call detection. Validated by the caller. | <pre>list(object({<br/>    event_name        = optional(string)<br/>    event_source      = optional(string)<br/>    user_identity_arn = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_cloudwatch_4_event_exclusions"></a> [cloudwatch\_4\_event\_exclusions](#input\_cloudwatch\_4\_event\_exclusions) | (Optional) Exclusions from CloudWatch.4 IAM policy change detection. Validated by the caller. | <pre>list(object({<br/>    event_name        = optional(string)<br/>    event_source      = optional(string)<br/>    role_name         = optional(string)<br/>    user_identity_arn = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudwatch_2_pattern"></a> [cloudwatch\_2\_pattern](#output\_cloudwatch\_2\_pattern) | CloudWatch.2 metric filter pattern without a trailing newline. Equals the historical literal when there are no exclusions. |
| <a name="output_cloudwatch_4_pattern"></a> [cloudwatch\_4\_pattern](#output\_cloudwatch\_4\_pattern) | CloudWatch.4 metric filter pattern without a trailing newline. Equals the historical literal when there are no exclusions. |
<!-- END_TF_DOCS -->
