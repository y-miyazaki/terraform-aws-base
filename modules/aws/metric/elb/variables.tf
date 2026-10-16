#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of ALB. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # ActiveConnectionCount threshold (unit=Count)
    active_connection_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ClientTLSNegotiationErrorCount threshold (unit=Count)
    client_tls_negotiation_error_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ConsumedLCUs threshold (unit=Count)
    consumed_lcus = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # HTTPCode_4XX_Count threshold (unit=Count)
    httpcode_4xx_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # HTTPCode_5XX_Count threshold (unit=Count)
    httpcode_5xx_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # HTTPCode_ELB_4XX_Count threshold (unit=Count)
    httpcode_elb_4xx_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # HTTPCode_ELB_5XX_Count threshold (unit=Count)
    httpcode_elb_5xx_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # TargetResponseTime threshold (unit=Seconds)
    target_response_time = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # TargetTLSNegotiationErrorCount threshold (unit=Count)
    target_tls_negotiation_error_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # UnHealthyHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    unhealthy_host_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })

    # Load Balancer Metrics (Additional)
    # DesyncMitigationMode_NonCompliant_Request_Count threshold (unit=Count)
    desync_mitigation_mode_non_compliant_request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # DroppedInvalidHeaderRequestCount threshold (unit=Count) [Requires AvailabilityZone dimension]
    dropped_invalid_header_request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ForwardedInvalidHeaderRequestCount threshold (unit=Count) [Requires AvailabilityZone dimension]
    forwarded_invalid_header_request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # GrpcRequestCount threshold (unit=Count)
    grpc_request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 100), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 100, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTP_Fixed_Response_Count threshold (unit=Count)
    http_fixed_response_count = optional(object({ enabled = optional(bool, false), value = optional(number, 100), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 100, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTP_Redirect_Count threshold (unit=Count)
    http_redirect_count = optional(object({ enabled = optional(bool, false), value = optional(number, 100), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 100, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTP_Redirect_Url_Limit_Exceeded_Count threshold (unit=Count)
    http_redirect_url_limit_exceeded_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTPCode_ELB_3XX_Count threshold (unit=Count)
    httpcode_elb_3xx_count = optional(object({ enabled = optional(bool, false), value = optional(number, 100), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 100, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTPCode_ELB_500_Count threshold (unit=Count)
    httpcode_elb_500_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTPCode_ELB_502_Count threshold (unit=Count)
    httpcode_elb_502_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTPCode_ELB_503_Count threshold (unit=Count)
    httpcode_elb_503_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTPCode_ELB_504_Count threshold (unit=Count)
    httpcode_elb_504_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # IPv6ProcessedBytes threshold (unit=Bytes)
    ipv6_processed_bytes = optional(object({ enabled = optional(bool, false), value = optional(number, 1073741824), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1073741824, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # IPv6RequestCount threshold (unit=Count)
    ipv6_request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1000), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1000, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # NewConnectionCount threshold (unit=Count)
    new_connection_count = optional(object({ enabled = optional(bool, false), value = optional(number, 10000), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 10000, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # NonStickyRequestCount threshold (unit=Count)
    non_sticky_request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1000), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1000, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ProcessedBytes threshold (unit=Bytes)
    processed_bytes = optional(object({ enabled = optional(bool, false), value = optional(number, 10737418240), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 10737418240, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # RejectedConnectionCount threshold (unit=Count)
    rejected_connection_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # RequestCount threshold (unit=Count)
    request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 10000), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 10000, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # RuleEvaluations threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    rule_evaluations = optional(object({ enabled = optional(bool, false), value = optional(number, 100000), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 100000, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # StandardProcessedBytes threshold (unit=Bytes)
    standard_processed_bytes = optional(object({ enabled = optional(bool, false), value = optional(number, 10737418240), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 10737418240, datapoints_to_alarm = 1, evaluation_periods = 1 })

    # LCU Metrics (Additional)
    # PeakLCUs threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    peak_lcus = optional(object({ enabled = optional(bool, false), value = optional(number, 10), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 10, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ReservedLCUs threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    reserved_lcus = optional(object({ enabled = optional(bool, false), value = optional(number, 10), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 10, datapoints_to_alarm = 1, evaluation_periods = 1 })

    # Target Metrics
    # AnomalousHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    anomalous_host_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HealthyHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    healthy_host_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTPCode_Target_2XX_Count threshold (unit=Count)
    httpcode_target_2xx_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HTTPCode_Target_3XX_Count threshold (unit=Count)
    httpcode_target_3xx_count = optional(object({ enabled = optional(bool, false), value = optional(number, 100), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 100, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # RequestCountPerTarget threshold (unit=Count) [Requires TargetGroup dimension]
    request_count_per_target = optional(object({ enabled = optional(bool, false), value = optional(number, 1000), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1000, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetConnectionErrorCount threshold (unit=Count)
    target_connection_error_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ZonalShiftedHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    zonal_shifted_host_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })

    # Target Group Health Metrics [All require LoadBalancer + TargetGroup dimensions]
    # HealthyStateDNS threshold (unit=Count) [Requires TargetGroup dimension]
    healthy_state_dns = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # HealthyStateRouting threshold (unit=Count) [Requires TargetGroup dimension]
    healthy_state_routing = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # UnhealthyRoutingRequestCount threshold (unit=Count) [Requires TargetGroup dimension]
    unhealthy_routing_request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # UnhealthyStateDNS threshold (unit=Count) [Requires TargetGroup dimension]
    unhealthy_state_dns = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # UnhealthyStateRouting threshold (unit=Count) [Requires TargetGroup dimension]
    unhealthy_state_routing = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })

    # User Authentication Metrics
    # ELBAuthError threshold (unit=Count)
    elb_auth_error = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ELBAuthFailure threshold (unit=Count)
    elb_auth_failure = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ELBAuthLatency threshold (unit=Milliseconds)
    elb_auth_latency = optional(object({ enabled = optional(bool, false), value = optional(number, 1000), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1000, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ELBAuthRefreshTokenSuccess threshold (unit=Count)
    elb_auth_refresh_token_success = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ELBAuthSuccess threshold (unit=Count)
    elb_auth_success = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # ELBAuthUserClaimsSizeExceeded threshold (unit=Count)
    elb_auth_user_claims_size_exceeded = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })

    # Lambda Function Metrics
    # LambdaInternalError threshold (unit=Count) [Requires TargetGroup dimension]
    lambda_internal_error = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # LambdaTargetProcessedBytes threshold (unit=Bytes) [LoadBalancer only, no AvailabilityZone]
    lambda_target_processed_bytes = optional(object({ enabled = optional(bool, false), value = optional(number, 1073741824), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1073741824, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # LambdaUserError threshold (unit=Count) [Requires TargetGroup dimension]
    lambda_user_error = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })

    # Target Optimizer Metrics
    # MitigatedHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    mitigated_host_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetControlActiveChannelCount threshold (unit=Count)
    target_control_active_channel_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetControlChannelErrorCount threshold (unit=Count)
    target_control_channel_error_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetControlNewChannelCount threshold (unit=Count)
    target_control_new_channel_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetControlProcessedBytes threshold (unit=Bytes)
    target_control_processed_bytes = optional(object({ enabled = optional(bool, false), value = optional(number, 1073741824), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1073741824, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetControlRequestCount threshold (unit=Count)
    target_control_request_count = optional(object({ enabled = optional(bool, false), value = optional(number, 100), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 100, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetControlRequestRejectCount threshold (unit=Count)
    target_control_request_reject_count = optional(object({ enabled = optional(bool, false), value = optional(number, 1), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 1, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetControlWorkQueueLength threshold (unit=Count)
    target_control_work_queue_length = optional(object({ enabled = optional(bool, false), value = optional(number, 100), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 100, datapoints_to_alarm = 1, evaluation_periods = 1 })
    # TargetOptimizerAnomalyScore threshold (unit=)
    target_optimizer_anomaly_score = optional(object({ enabled = optional(bool, false), value = optional(number, 0.5), datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) }), { enabled = false, value = 0.5, datapoints_to_alarm = 1, evaluation_periods = 1 })
  })
  description = "(Optional) Set the threshold for each Metric in ALB."
  default = {
    active_connection_count            = { enabled = true, value = 10000 }
    client_tls_negotiation_error_count = { enabled = true, value = 10 }
    consumed_lcus                      = { enabled = true, value = 5 }
    httpcode_4xx_count                 = { enabled = true, value = 1 }
    httpcode_5xx_count                 = { enabled = true, value = 1 }
    httpcode_elb_4xx_count             = { enabled = true, value = 1 }
    httpcode_elb_5xx_count             = { enabled = true, value = 1 }
    target_response_time               = { enabled = true, value = 10 }
    target_tls_negotiation_error_count = { enabled = true, value = 10 }
    unhealthy_host_count               = { enabled = true, value = 1 }
  }
}

variable "threshold_override" {
  type = map(object({
    # ActiveConnectionCount threshold (unit=Count)
    active_connection_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ClientTLSNegotiationErrorCount threshold (unit=Count)
    client_tls_negotiation_error_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ConsumedLCUs threshold (unit=Count)
    consumed_lcus = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_4XX_Count threshold (unit=Count)
    httpcode_4xx_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_5XX_Count threshold (unit=Count)
    httpcode_5xx_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_ELB_4XX_Count threshold (unit=Count)
    httpcode_elb_4xx_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_ELB_5XX_Count threshold (unit=Count)
    httpcode_elb_5xx_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetResponseTime threshold (unit=Seconds)
    target_response_time = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetTLSNegotiationErrorCount threshold (unit=Count)
    target_tls_negotiation_error_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # UnHealthyHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    unhealthy_host_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))

    # Load Balancer Metrics (Additional)
    # DesyncMitigationMode_NonCompliant_Request_Count threshold (unit=Count)
    desync_mitigation_mode_non_compliant_request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DroppedInvalidHeaderRequestCount threshold (unit=Count) [Requires AvailabilityZone dimension]
    dropped_invalid_header_request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ForwardedInvalidHeaderRequestCount threshold (unit=Count) [Requires AvailabilityZone dimension]
    forwarded_invalid_header_request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # GrpcRequestCount threshold (unit=Count)
    grpc_request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTP_Fixed_Response_Count threshold (unit=Count)
    http_fixed_response_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTP_Redirect_Count threshold (unit=Count)
    http_redirect_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTP_Redirect_Url_Limit_Exceeded_Count threshold (unit=Count)
    http_redirect_url_limit_exceeded_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_ELB_3XX_Count threshold (unit=Count)
    httpcode_elb_3xx_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_ELB_500_Count threshold (unit=Count)
    httpcode_elb_500_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_ELB_502_Count threshold (unit=Count)
    httpcode_elb_502_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_ELB_503_Count threshold (unit=Count)
    httpcode_elb_503_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_ELB_504_Count threshold (unit=Count)
    httpcode_elb_504_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # IPv6ProcessedBytes threshold (unit=Bytes)
    ipv6_processed_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # IPv6RequestCount threshold (unit=Count)
    ipv6_request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NewConnectionCount threshold (unit=Count)
    new_connection_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NonStickyRequestCount threshold (unit=Count)
    non_sticky_request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ProcessedBytes threshold (unit=Bytes)
    processed_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # RejectedConnectionCount threshold (unit=Count)
    rejected_connection_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # RequestCount threshold (unit=Count)
    request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # RuleEvaluations threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    rule_evaluations = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # StandardProcessedBytes threshold (unit=Bytes)
    standard_processed_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))

    # LCU Metrics (Additional)
    # PeakLCUs threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    peak_lcus = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReservedLCUs threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    reserved_lcus = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))

    # Target Metrics
    # AnomalousHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    anomalous_host_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HealthyHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    healthy_host_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_Target_2XX_Count threshold (unit=Count)
    httpcode_target_2xx_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HTTPCode_Target_3XX_Count threshold (unit=Count)
    httpcode_target_3xx_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # RequestCountPerTarget threshold (unit=Count) [Requires TargetGroup dimension]
    request_count_per_target = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetConnectionErrorCount threshold (unit=Count)
    target_connection_error_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ZonalShiftedHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    zonal_shifted_host_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))

    # Target Group Health Metrics [All require LoadBalancer + TargetGroup dimensions]
    # HealthyStateDNS threshold (unit=Count) [Requires TargetGroup dimension]
    healthy_state_dns = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HealthyStateRouting threshold (unit=Count) [Requires TargetGroup dimension]
    healthy_state_routing = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # UnhealthyRoutingRequestCount threshold (unit=Count) [Requires TargetGroup dimension]
    unhealthy_routing_request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # UnhealthyStateDNS threshold (unit=Count) [Requires TargetGroup dimension]
    unhealthy_state_dns = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # UnhealthyStateRouting threshold (unit=Count) [Requires TargetGroup dimension]
    unhealthy_state_routing = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))

    # User Authentication Metrics
    # ELBAuthError threshold (unit=Count)
    elb_auth_error = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ELBAuthFailure threshold (unit=Count)
    elb_auth_failure = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ELBAuthLatency threshold (unit=Milliseconds)
    elb_auth_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ELBAuthRefreshTokenSuccess threshold (unit=Count)
    elb_auth_refresh_token_success = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ELBAuthSuccess threshold (unit=Count)
    elb_auth_success = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ELBAuthUserClaimsSizeExceeded threshold (unit=Count)
    elb_auth_user_claims_size_exceeded = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))

    # Lambda Function Metrics
    # LambdaInternalError threshold (unit=Count) [Requires TargetGroup dimension]
    lambda_internal_error = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # LambdaTargetProcessedBytes threshold (unit=Bytes) [LoadBalancer only, no AvailabilityZone]
    lambda_target_processed_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # LambdaUserError threshold (unit=Count) [Requires TargetGroup dimension]
    lambda_user_error = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))

    # Target Optimizer Metrics
    # MitigatedHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    mitigated_host_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetControlActiveChannelCount threshold (unit=Count)
    target_control_active_channel_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetControlChannelErrorCount threshold (unit=Count)
    target_control_channel_error_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetControlNewChannelCount threshold (unit=Count)
    target_control_new_channel_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetControlProcessedBytes threshold (unit=Bytes)
    target_control_processed_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetControlRequestCount threshold (unit=Count)
    target_control_request_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetControlRequestRejectCount threshold (unit=Count)
    target_control_request_reject_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetControlWorkQueueLength threshold (unit=Count)
    target_control_work_queue_length = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetOptimizerAnomalyScore threshold (unit=)
    target_optimizer_anomaly_score = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the LoadBalancer. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of ELBs (ALB/NLB) to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of ELBs will be automatically registered, but at that time, specify the ELB name you want to exclude using partial match."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of ELBs will be automatically registered, but at that time, specify the ELB name you want to include using partial match. If empty, all ELBs will be included (except excluded ones)."
  default     = []
}

variable "dimensions" {
  type        = list(map(any))
  description = "(Optional) If create_auto_dimensions is set to false, The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
  default     = []
}

variable "name_prefix" {
  type        = string
  description = "(Required) CloudWatch Filter/Alarm name prefix."
}

variable "alarm_actions" {
  type        = list(string)
  description = "(Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "ok_actions" {
  type        = list(string)
  description = "(Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}

variable "insufficient_data_actions" {
  type        = list(string)
  description = "(Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
