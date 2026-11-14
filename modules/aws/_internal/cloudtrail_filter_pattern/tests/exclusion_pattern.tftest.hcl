run "default_patterns_have_no_exclusion_clause" {
  command = plan

  assert {
    condition     = !strcontains(output.cloudwatch_2_pattern, "&& (($.eventSource")
    error_message = "CloudWatch.2 pattern must have no exclusion clause by default"
  }
  assert {
    condition     = startswith(output.cloudwatch_4_pattern, "{($.eventName=DeleteGroupPolicy)") && endswith(output.cloudwatch_4_pattern, "DetachGroupPolicy)}")
    error_message = "CloudWatch.4 pattern must equal the plain event term list by default"
  }
}

run "empty_exclusion_is_dropped" {
  command = plan

  variables {
    cloudwatch_2_event_exclusions = [{}]
    cloudwatch_4_event_exclusions = [{}]
  }

  assert {
    condition     = !strcontains(output.cloudwatch_2_pattern, "()") && !strcontains(output.cloudwatch_4_pattern, "()")
    error_message = "an exclusion with no key must not render an empty clause"
  }
}

run "set_keys_are_anded_in_stable_order" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [
      { role_name = "r", user_identity_arn = "a", event_name = "PutRolePolicy" },
    ]
  }

  assert {
    condition     = strcontains(output.cloudwatch_4_pattern, " && (($.eventName!=\"PutRolePolicy\") || ($.userIdentity.arn!=\"a\") || ($.requestParameters.roleName!=\"r\"))}")
    error_message = "keys must be rendered in event_source, event_name, user_identity_arn, role_name order"
  }
}
