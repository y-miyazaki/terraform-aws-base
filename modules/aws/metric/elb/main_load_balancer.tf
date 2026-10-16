#--------------------------------------------------------------
# Load Balancer Metrics
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------

#--------------------------------------------------------------
# For ActiveConnectionCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "active_connection_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].active_connection_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB active connection count>(>= ${local.effective_thresholds[each.key].active_connection_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-active-connection-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].active_connection_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].active_connection_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ActiveConnectionCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].active_connection_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ClientTLSNegotiationErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "client_tls_negotiation_error_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].client_tls_negotiation_error_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB client tls negotiation error count>(>= ${local.effective_thresholds[each.key].client_tls_negotiation_error_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-client-tls-negotiation-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].client_tls_negotiation_error_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].client_tls_negotiation_error_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ClientTLSNegotiationErrorCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].client_tls_negotiation_error_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For DesyncMitigationMode_NonCompliant_Request_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "desync_mitigation_mode_non_compliant_request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].desync_mitigation_mode_non_compliant_request_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB desync mitigation mode non compliant request count>(>= ${local.effective_thresholds[each.key].desync_mitigation_mode_non_compliant_request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-desync-mitigation-mode-non-compliant-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].desync_mitigation_mode_non_compliant_request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].desync_mitigation_mode_non_compliant_request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DesyncMitigationMode_NonCompliant_Request_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].desync_mitigation_mode_non_compliant_request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For DroppedInvalidHeaderRequestCount
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires AvailabilityZone + LoadBalancer dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dropped_invalid_header_request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].dropped_invalid_header_request_count.enabled && contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB dropped invalid header request count>(>= ${local.effective_thresholds[each.key].dropped_invalid_header_request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-dropped-invalid-header-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].dropped_invalid_header_request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].dropped_invalid_header_request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DroppedInvalidHeaderRequestCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].dropped_invalid_header_request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ForwardedInvalidHeaderRequestCount
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires AvailabilityZone + LoadBalancer dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "forwarded_invalid_header_request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].forwarded_invalid_header_request_count.enabled && contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB forwarded invalid header request count>(>= ${local.effective_thresholds[each.key].forwarded_invalid_header_request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-forwarded-invalid-header-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].forwarded_invalid_header_request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].forwarded_invalid_header_request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ForwardedInvalidHeaderRequestCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].forwarded_invalid_header_request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For GrpcRequestCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "grpc_request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].grpc_request_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB grpc request count>(>= ${local.effective_thresholds[each.key].grpc_request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-grpc-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].grpc_request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].grpc_request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "GrpcRequestCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].grpc_request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTP_Fixed_Response_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_fixed_response_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].http_fixed_response_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB http fixed response count>(>= ${local.effective_thresholds[each.key].http_fixed_response_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-http-fixed-response-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].http_fixed_response_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].http_fixed_response_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTP_Fixed_Response_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].http_fixed_response_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTP_Redirect_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_redirect_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].http_redirect_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB http redirect count>(>= ${local.effective_thresholds[each.key].http_redirect_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-http-redirect-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].http_redirect_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].http_redirect_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTP_Redirect_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].http_redirect_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTP_Redirect_Url_Limit_Exceeded_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_redirect_url_limit_exceeded_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].http_redirect_url_limit_exceeded_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB http redirect url limit exceeded count>(>= ${local.effective_thresholds[each.key].http_redirect_url_limit_exceeded_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-http-redirect-url-limit-exceeded-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].http_redirect_url_limit_exceeded_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].http_redirect_url_limit_exceeded_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTP_Redirect_Url_Limit_Exceeded_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].http_redirect_url_limit_exceeded_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_ELB_3XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_3xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_elb_3xx_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 3xx count>(>= ${local.effective_thresholds[each.key].httpcode_elb_3xx_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-elb-3xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_elb_3xx_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_elb_3xx_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_ELB_3XX_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_elb_3xx_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_ELB_4XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_4xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_elb_4xx_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 4xx count>(>= ${local.effective_thresholds[each.key].httpcode_elb_4xx_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-elb-4xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_elb_4xx_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_elb_4xx_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_ELB_4XX_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_elb_4xx_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_ELB_5XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_5xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_elb_5xx_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 5xx count>(>= ${local.effective_thresholds[each.key].httpcode_elb_5xx_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-elb-5xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_elb_5xx_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_elb_5xx_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_ELB_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_elb_5xx_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_ELB_500_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_500_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_elb_500_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 500 count>(>= ${local.effective_thresholds[each.key].httpcode_elb_500_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-elb-500-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_elb_500_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_elb_500_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_ELB_500_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_elb_500_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_ELB_502_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_502_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_elb_502_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 502 count>(>= ${local.effective_thresholds[each.key].httpcode_elb_502_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-elb-502-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_elb_502_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_elb_502_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_ELB_502_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_elb_502_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_ELB_503_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_503_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_elb_503_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 503 count>(>= ${local.effective_thresholds[each.key].httpcode_elb_503_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-elb-503-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_elb_503_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_elb_503_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_ELB_503_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_elb_503_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_ELB_504_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_504_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_elb_504_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 504 count>(>= ${local.effective_thresholds[each.key].httpcode_elb_504_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-elb-504-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_elb_504_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_elb_504_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_ELB_504_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_elb_504_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For IPv6ProcessedBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ipv6_processed_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].ipv6_processed_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB ipv6 processed bytes>(>= ${local.effective_thresholds[each.key].ipv6_processed_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-ipv6-processed-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].ipv6_processed_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].ipv6_processed_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "IPv6ProcessedBytes"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].ipv6_processed_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For IPv6RequestCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ipv6_request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].ipv6_request_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB ipv6 request count>(>= ${local.effective_thresholds[each.key].ipv6_request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-ipv6-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].ipv6_request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].ipv6_request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "IPv6RequestCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].ipv6_request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NewConnectionCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "new_connection_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].new_connection_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB new connection count>(>= ${local.effective_thresholds[each.key].new_connection_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-new-connection-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].new_connection_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].new_connection_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NewConnectionCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].new_connection_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ProcessedBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "processed_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].processed_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB processed bytes>(>= ${local.effective_thresholds[each.key].processed_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-processed-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].processed_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].processed_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ProcessedBytes"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].processed_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For RejectedConnectionCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rejected_connection_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].rejected_connection_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB rejected connection count>(>= ${local.effective_thresholds[each.key].rejected_connection_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-rejected-connection-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].rejected_connection_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].rejected_connection_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "RejectedConnectionCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].rejected_connection_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For RequestCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].request_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB request count>(>= ${local.effective_thresholds[each.key].request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "RequestCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For RuleEvaluations
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric only supports LoadBalancer dimension (no AvailabilityZone)
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rule_evaluations" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].rule_evaluations.enabled && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB rule evaluations>(>= ${local.effective_thresholds[each.key].rule_evaluations.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-rule-evaluations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].rule_evaluations.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].rule_evaluations.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "RuleEvaluations"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].rule_evaluations.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NonStickyRequestCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "non_sticky_request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].non_sticky_request_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB non sticky request count>(>= ${local.effective_thresholds[each.key].non_sticky_request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-non-sticky-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].non_sticky_request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].non_sticky_request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NonStickyRequestCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].non_sticky_request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For StandardProcessedBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "standard_processed_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].standard_processed_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB standard processed bytes>(>= ${local.effective_thresholds[each.key].standard_processed_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-standard-processed-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].standard_processed_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].standard_processed_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "StandardProcessedBytes"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].standard_processed_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}
