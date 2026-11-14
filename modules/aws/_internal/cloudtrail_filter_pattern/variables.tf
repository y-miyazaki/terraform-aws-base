variable "cloudwatch_2_event_exclusions" {
  type = list(object({
    event_name        = optional(string)
    event_source      = optional(string)
    user_identity_arn = optional(string)
  }))
  description = "(Optional) Exclusions from CloudWatch.2 unauthorized API call detection. Validated by the caller."
  default     = []
}

variable "cloudwatch_4_event_exclusions" {
  type = list(object({
    event_name        = optional(string)
    event_source      = optional(string)
    role_name         = optional(string)
    user_identity_arn = optional(string)
  }))
  description = "(Optional) Exclusions from CloudWatch.4 IAM policy change detection. Validated by the caller."
  default     = []
}
