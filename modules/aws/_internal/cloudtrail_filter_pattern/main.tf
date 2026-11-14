#--------------------------------------------------------------
# Module: aws/_internal/cloudtrail_filter_pattern
# Purpose: Build CloudWatch.2 / CloudWatch.4 CloudTrail metric filter patterns with event exclusions.
# Notes: Internal helper module for aws/security/cloudtrail/*; not intended for direct use.
#        Pure computation (no resources). Validation of the exclusion inputs stays with the caller.
#--------------------------------------------------------------

locals {
  # Exclusion key => CloudTrail record path.
  exclusion_paths = {
    event_name        = "eventName"
    event_source      = "eventSource"
    role_name         = "requestParameters.roleName"
    user_identity_arn = "userIdentity.arn"
  }

  # Evaluation order of the exclusion keys inside a clause (kept stable so patterns do not change).
  cloudwatch_2_fields = ["event_source", "event_name", "user_identity_arn"]
  cloudwatch_4_fields = ["event_source", "event_name", "user_identity_arn", "role_name"]

  # All exclusion keys are optional; only the set keys are ANDed (an exclusion matches only when every set key matches).
  # CloudWatch filter patterns do not support !(...); use De Morgan: !(A && B && ...) => (!A || !B || ...)
  cloudwatch_2_exclusion_clauses = [
    for exclusion in var.cloudwatch_2_event_exclusions :
    # An exclusion with no key set is dropped (it would otherwise render the invalid clause " && ()").
    format(" && (%s)", join(" || ", [
      for field in local.cloudwatch_2_fields :
      format("($.%s!=\"%s\")", local.exclusion_paths[field], exclusion[field]) if exclusion[field] != null
    ]))
    if anytrue([for field in local.cloudwatch_2_fields : exclusion[field] != null])
  ]

  cloudwatch_4_exclusion_clauses = [
    for exclusion in var.cloudwatch_4_event_exclusions :
    # An exclusion with no key set is dropped (see cloudwatch_2).
    format(" && (%s)", join(" || ", [
      for field in local.cloudwatch_4_fields :
      format("($.%s!=\"%s\")", local.exclusion_paths[field], exclusion[field]) if exclusion[field] != null
    ]))
    if anytrue([for field in local.cloudwatch_4_fields : exclusion[field] != null])
  ]

  cloudwatch_4_event_terms = "($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy)"
}
