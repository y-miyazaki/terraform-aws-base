#--------------------------------------------------------------
# Outputs for cloudtrail_filter_pattern internal module
#--------------------------------------------------------------

output "cloudwatch_2_pattern" {
  description = "CloudWatch.2 metric filter pattern without a trailing newline. Equals the historical literal when there are no exclusions."
  value = join("", concat(
    ["{(($.errorCode=\"*UnauthorizedOperation\") || ($.errorCode=\"AccessDenied*\")) && ($.userIdentity.arn!=\"*assumed-role/AWSServiceRoleFor*\") && ($.userIdentity.arn!=\"*assumed-role/AIOpsRole*\")"],
    local.cloudwatch_2_exclusion_clauses,
    ["}"]
  ))
}

output "cloudwatch_4_pattern" {
  description = "CloudWatch.4 metric filter pattern without a trailing newline. Equals the historical literal when there are no exclusions."
  value = (
    length(local.cloudwatch_4_exclusion_clauses) == 0
    ? "{${local.cloudwatch_4_event_terms}}"
    : "{(${local.cloudwatch_4_event_terms})${join("", local.cloudwatch_4_exclusion_clauses)}}"
  )
}
