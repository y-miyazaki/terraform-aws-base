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
    enabled_active_connection_count = bool
    active_connection_count         = number
    # ClientTLSNegotiationErrorCount threshold (unit=Count)
    enabled_client_tls_negotiation_error_count = bool
    client_tls_negotiation_error_count         = number
    # ConsumedLCUs threshold (unit=Count)
    enabled_consumed_lcus = bool
    consumed_lcus         = number
    # HTTPCode_4XX_Count threshold (unit=Count)
    enabled_httpcode_4xx_count = bool
    httpcode_4xx_count         = number
    # HTTPCode_5XX_Count threshold (unit=Count)
    enabled_httpcode_5xx_count = bool
    httpcode_5xx_count         = number
    # HTTPCode_ELB_4XX_Count threshold (unit=Count)
    enabled_httpcode_elb_4xx_count = bool
    httpcode_elb_4xx_count         = number
    # HTTPCode_ELB_5XX_Count threshold (unit=Count)
    enabled_httpcode_elb_5xx_count = bool
    httpcode_elb_5xx_count         = number
    # TargetResponseTime threshold (unit=Seconds)
    enabled_target_response_time = bool
    target_response_time         = number
    # TargetTLSNegotiationErrorCount threshold (unit=Count)
    enabled_target_tls_negotiation_error_count = bool
    target_tls_negotiation_error_count         = number
    # UnHealthyHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_unhealthy_host_count = bool
    unhealthy_host_count         = number

    # Load Balancer Metrics (Additional)
    # DesyncMitigationMode_NonCompliant_Request_Count threshold (unit=Count)
    enabled_desync_mitigation_mode_non_compliant_request_count = optional(bool, false)
    desync_mitigation_mode_non_compliant_request_count         = optional(number, 1)
    # DroppedInvalidHeaderRequestCount threshold (unit=Count) [Requires AvailabilityZone dimension]
    enabled_dropped_invalid_header_request_count = optional(bool, false)
    dropped_invalid_header_request_count         = optional(number, 1)
    # ForwardedInvalidHeaderRequestCount threshold (unit=Count) [Requires AvailabilityZone dimension]
    enabled_forwarded_invalid_header_request_count = optional(bool, false)
    forwarded_invalid_header_request_count         = optional(number, 1)
    # GrpcRequestCount threshold (unit=Count)
    enabled_grpc_request_count = optional(bool, false)
    grpc_request_count         = optional(number, 100)
    # HTTP_Fixed_Response_Count threshold (unit=Count)
    enabled_http_fixed_response_count = optional(bool, false)
    http_fixed_response_count         = optional(number, 100)
    # HTTP_Redirect_Count threshold (unit=Count)
    enabled_http_redirect_count = optional(bool, false)
    http_redirect_count         = optional(number, 100)
    # HTTP_Redirect_Url_Limit_Exceeded_Count threshold (unit=Count)
    enabled_http_redirect_url_limit_exceeded_count = optional(bool, false)
    http_redirect_url_limit_exceeded_count         = optional(number, 1)
    # HTTPCode_ELB_3XX_Count threshold (unit=Count)
    enabled_httpcode_elb_3xx_count = optional(bool, false)
    httpcode_elb_3xx_count         = optional(number, 100)
    # HTTPCode_ELB_500_Count threshold (unit=Count)
    enabled_httpcode_elb_500_count = optional(bool, false)
    httpcode_elb_500_count         = optional(number, 1)
    # HTTPCode_ELB_502_Count threshold (unit=Count)
    enabled_httpcode_elb_502_count = optional(bool, false)
    httpcode_elb_502_count         = optional(number, 1)
    # HTTPCode_ELB_503_Count threshold (unit=Count)
    enabled_httpcode_elb_503_count = optional(bool, false)
    httpcode_elb_503_count         = optional(number, 1)
    # HTTPCode_ELB_504_Count threshold (unit=Count)
    enabled_httpcode_elb_504_count = optional(bool, false)
    httpcode_elb_504_count         = optional(number, 1)
    # IPv6ProcessedBytes threshold (unit=Bytes)
    enabled_ipv6_processed_bytes = optional(bool, false)
    ipv6_processed_bytes         = optional(number, 1073741824)
    # IPv6RequestCount threshold (unit=Count)
    enabled_ipv6_request_count = optional(bool, false)
    ipv6_request_count         = optional(number, 1000)
    # NewConnectionCount threshold (unit=Count)
    enabled_new_connection_count = optional(bool, false)
    new_connection_count         = optional(number, 10000)
    # NonStickyRequestCount threshold (unit=Count)
    enabled_non_sticky_request_count = optional(bool, false)
    non_sticky_request_count         = optional(number, 1000)
    # ProcessedBytes threshold (unit=Bytes)
    enabled_processed_bytes = optional(bool, false)
    processed_bytes         = optional(number, 10737418240)
    # RejectedConnectionCount threshold (unit=Count)
    enabled_rejected_connection_count = optional(bool, false)
    rejected_connection_count         = optional(number, 1)
    # RequestCount threshold (unit=Count)
    enabled_request_count = optional(bool, false)
    request_count         = optional(number, 10000)
    # RuleEvaluations threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    enabled_rule_evaluations = optional(bool, false)
    rule_evaluations         = optional(number, 100000)
    # StandardProcessedBytes threshold (unit=Bytes)
    enabled_standard_processed_bytes = optional(bool, false)
    standard_processed_bytes         = optional(number, 10737418240)

    # LCU Metrics (Additional)
    # PeakLCUs threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    enabled_peak_lcus = optional(bool, false)
    peak_lcus         = optional(number, 10)
    # ReservedLCUs threshold (unit=Count) [LoadBalancer only, no AvailabilityZone]
    enabled_reserved_lcus = optional(bool, false)
    reserved_lcus         = optional(number, 10)

    # Target Metrics
    # AnomalousHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_anomalous_host_count = optional(bool, false)
    anomalous_host_count         = optional(number, 1)
    # HealthyHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_healthy_host_count = optional(bool, false)
    healthy_host_count         = optional(number, 1)
    # HTTPCode_Target_2XX_Count threshold (unit=Count)
    enabled_httpcode_target_2xx_count = optional(bool, false)
    httpcode_target_2xx_count         = optional(number, 1)
    # HTTPCode_Target_3XX_Count threshold (unit=Count)
    enabled_httpcode_target_3xx_count = optional(bool, false)
    httpcode_target_3xx_count         = optional(number, 100)
    # RequestCountPerTarget threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_request_count_per_target = optional(bool, false)
    request_count_per_target         = optional(number, 1000)
    # TargetConnectionErrorCount threshold (unit=Count)
    enabled_target_connection_error_count = optional(bool, false)
    target_connection_error_count         = optional(number, 1)
    # ZonalShiftedHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_zonal_shifted_host_count = optional(bool, false)
    zonal_shifted_host_count         = optional(number, 1)

    # Target Group Health Metrics [All require LoadBalancer + TargetGroup dimensions]
    # HealthyStateDNS threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_healthy_state_dns = optional(bool, false)
    healthy_state_dns         = optional(number, 1)
    # HealthyStateRouting threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_healthy_state_routing = optional(bool, false)
    healthy_state_routing         = optional(number, 1)
    # UnhealthyRoutingRequestCount threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_unhealthy_routing_request_count = optional(bool, false)
    unhealthy_routing_request_count         = optional(number, 1)
    # UnhealthyStateDNS threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_unhealthy_state_dns = optional(bool, false)
    unhealthy_state_dns         = optional(number, 1)
    # UnhealthyStateRouting threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_unhealthy_state_routing = optional(bool, false)
    unhealthy_state_routing         = optional(number, 1)

    # User Authentication Metrics
    # ELBAuthError threshold (unit=Count)
    enabled_elb_auth_error = optional(bool, false)
    elb_auth_error         = optional(number, 1)
    # ELBAuthFailure threshold (unit=Count)
    enabled_elb_auth_failure = optional(bool, false)
    elb_auth_failure         = optional(number, 1)
    # ELBAuthLatency threshold (unit=Milliseconds)
    enabled_elb_auth_latency = optional(bool, false)
    elb_auth_latency         = optional(number, 1000)
    # ELBAuthRefreshTokenSuccess threshold (unit=Count)
    enabled_elb_auth_refresh_token_success = optional(bool, false)
    elb_auth_refresh_token_success         = optional(number, 1)
    # ELBAuthSuccess threshold (unit=Count)
    enabled_elb_auth_success = optional(bool, false)
    elb_auth_success         = optional(number, 1)
    # ELBAuthUserClaimsSizeExceeded threshold (unit=Count)
    enabled_elb_auth_user_claims_size_exceeded = optional(bool, false)
    elb_auth_user_claims_size_exceeded         = optional(number, 1)

    # Lambda Function Metrics
    # LambdaInternalError threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_lambda_internal_error = optional(bool, false)
    lambda_internal_error         = optional(number, 1)
    # LambdaTargetProcessedBytes threshold (unit=Bytes) [LoadBalancer only, no AvailabilityZone]
    enabled_lambda_target_processed_bytes = optional(bool, false)
    lambda_target_processed_bytes         = optional(number, 1073741824)
    # LambdaUserError threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_lambda_user_error = optional(bool, false)
    lambda_user_error         = optional(number, 1)

    # Target Optimizer Metrics
    # MitigatedHostCount threshold (unit=Count) [Requires TargetGroup dimension]
    enabled_mitigated_host_count = optional(bool, false)
    mitigated_host_count         = optional(number, 1)
    # TargetControlActiveChannelCount threshold (unit=Count)
    enabled_target_control_active_channel_count = optional(bool, false)
    target_control_active_channel_count         = optional(number, 1)
    # TargetControlChannelErrorCount threshold (unit=Count)
    enabled_target_control_channel_error_count = optional(bool, false)
    target_control_channel_error_count         = optional(number, 1)
    # TargetControlNewChannelCount threshold (unit=Count)
    enabled_target_control_new_channel_count = optional(bool, false)
    target_control_new_channel_count         = optional(number, 1)
    # TargetControlProcessedBytes threshold (unit=Bytes)
    enabled_target_control_processed_bytes = optional(bool, false)
    target_control_processed_bytes         = optional(number, 1073741824)
    # TargetControlRequestCount threshold (unit=Count)
    enabled_target_control_request_count = optional(bool, false)
    target_control_request_count         = optional(number, 100)
    # TargetControlRequestRejectCount threshold (unit=Count)
    enabled_target_control_request_reject_count = optional(bool, false)
    target_control_request_reject_count         = optional(number, 1)
    # TargetControlWorkQueueLength threshold (unit=Count)
    enabled_target_control_work_queue_length = optional(bool, false)
    target_control_work_queue_length         = optional(number, 100)
    # TargetOptimizerAnomalyScore threshold (unit=)
    enabled_target_optimizer_anomaly_score = optional(bool, false)
    target_optimizer_anomaly_score         = optional(number, 0.5)
    }
  )
  description = "(Optional) Set the threshold for each Metric in ALB."
  default = {
    enabled_active_connection_count            = true
    active_connection_count                    = 10000
    enabled_client_tls_negotiation_error_count = true
    client_tls_negotiation_error_count         = 10
    enabled_consumed_lcus                      = true
    consumed_lcus                              = 5
    enabled_httpcode_4xx_count                 = true
    httpcode_4xx_count                         = 1
    enabled_httpcode_5xx_count                 = true
    httpcode_5xx_count                         = 1
    enabled_httpcode_elb_4xx_count             = true
    httpcode_elb_4xx_count                     = 1
    enabled_httpcode_elb_5xx_count             = true
    httpcode_elb_5xx_count                     = 1
    enabled_target_response_time               = true
    target_response_time                       = 10
    enabled_target_tls_negotiation_error_count = true
    target_tls_negotiation_error_count         = 10
    enabled_unhealthy_host_count               = true
    unhealthy_host_count                       = 1
  }
}

variable "threshold_override" {
  type = map(object({
    # (Optional) ActiveConnectionCount threshold (unit=Count)
    enabled_active_connection_count = optional(bool)
    active_connection_count         = optional(number)
    # (Optional) ClientTLSNegotiationErrorCount threshold (unit=Count)
    enabled_client_tls_negotiation_error_count = optional(bool)
    client_tls_negotiation_error_count         = optional(number)
    # (Optional) ConsumedLCUs threshold (unit=Count)
    enabled_consumed_lcus = optional(bool)
    consumed_lcus         = optional(number)
    # (Optional) HTTPCode_4XX_Count threshold (unit=Count)
    enabled_httpcode_4xx_count = optional(bool)
    httpcode_4xx_count         = optional(number)
    # (Optional) HTTPCode_5XX_Count threshold (unit=Count)
    enabled_httpcode_5xx_count = optional(bool)
    httpcode_5xx_count         = optional(number)
    # (Optional) HTTPCode_ELB_4XX_Count threshold (unit=Count)
    enabled_httpcode_elb_4xx_count = optional(bool)
    httpcode_elb_4xx_count         = optional(number)
    # (Optional) HTTPCode_ELB_5XX_Count threshold (unit=Count)
    enabled_httpcode_elb_5xx_count = optional(bool)
    httpcode_elb_5xx_count         = optional(number)
    # (Optional) TargetResponseTime threshold (unit=Seconds)
    enabled_target_response_time = optional(bool)
    target_response_time         = optional(number)
    # (Optional) TargetTLSNegotiationErrorCount threshold (unit=Count)
    enabled_target_tls_negotiation_error_count = optional(bool)
    target_tls_negotiation_error_count         = optional(number)
    # (Optional) UnHealthyHostCount threshold (unit=Count)
    enabled_unhealthy_host_count = optional(bool)
    unhealthy_host_count         = optional(number)

    # Load Balancer Metrics (Additional)
    enabled_desync_mitigation_mode_non_compliant_request_count = optional(bool)
    desync_mitigation_mode_non_compliant_request_count         = optional(number)
    enabled_dropped_invalid_header_request_count               = optional(bool)
    dropped_invalid_header_request_count                       = optional(number)
    enabled_forwarded_invalid_header_request_count             = optional(bool)
    forwarded_invalid_header_request_count                     = optional(number)
    enabled_grpc_request_count                                 = optional(bool)
    grpc_request_count                                         = optional(number)
    enabled_http_fixed_response_count                          = optional(bool)
    http_fixed_response_count                                  = optional(number)
    enabled_http_redirect_count                                = optional(bool)
    http_redirect_count                                        = optional(number)
    enabled_http_redirect_url_limit_exceeded_count             = optional(bool)
    http_redirect_url_limit_exceeded_count                     = optional(number)
    enabled_httpcode_elb_3xx_count                             = optional(bool)
    httpcode_elb_3xx_count                                     = optional(number)
    enabled_httpcode_elb_500_count                             = optional(bool)
    httpcode_elb_500_count                                     = optional(number)
    enabled_httpcode_elb_502_count                             = optional(bool)
    httpcode_elb_502_count                                     = optional(number)
    enabled_httpcode_elb_503_count                             = optional(bool)
    httpcode_elb_503_count                                     = optional(number)
    enabled_httpcode_elb_504_count                             = optional(bool)
    httpcode_elb_504_count                                     = optional(number)
    enabled_ipv6_processed_bytes                               = optional(bool)
    ipv6_processed_bytes                                       = optional(number)
    enabled_ipv6_request_count                                 = optional(bool)
    ipv6_request_count                                         = optional(number)
    enabled_new_connection_count                               = optional(bool)
    new_connection_count                                       = optional(number)
    enabled_non_sticky_request_count                           = optional(bool)
    non_sticky_request_count                                   = optional(number)
    enabled_processed_bytes                                    = optional(bool)
    processed_bytes                                            = optional(number)
    enabled_rejected_connection_count                          = optional(bool)
    rejected_connection_count                                  = optional(number)
    enabled_request_count                                      = optional(bool)
    request_count                                              = optional(number)
    enabled_rule_evaluations                                   = optional(bool)
    rule_evaluations                                           = optional(number)
    enabled_standard_processed_bytes                           = optional(bool)
    standard_processed_bytes                                   = optional(number)

    # LCU Metrics (Additional)
    enabled_peak_lcus     = optional(bool)
    peak_lcus             = optional(number)
    enabled_reserved_lcus = optional(bool)
    reserved_lcus         = optional(number)

    # Target Metrics
    enabled_anomalous_host_count          = optional(bool)
    anomalous_host_count                  = optional(number)
    enabled_healthy_host_count            = optional(bool)
    healthy_host_count                    = optional(number)
    enabled_httpcode_target_2xx_count     = optional(bool)
    httpcode_target_2xx_count             = optional(number)
    enabled_httpcode_target_3xx_count     = optional(bool)
    httpcode_target_3xx_count             = optional(number)
    enabled_request_count_per_target      = optional(bool)
    request_count_per_target              = optional(number)
    enabled_target_connection_error_count = optional(bool)
    target_connection_error_count         = optional(number)
    enabled_zonal_shifted_host_count      = optional(bool)
    zonal_shifted_host_count              = optional(number)

    # Target Group Health Metrics
    enabled_healthy_state_dns               = optional(bool)
    healthy_state_dns                       = optional(number)
    enabled_healthy_state_routing           = optional(bool)
    healthy_state_routing                   = optional(number)
    enabled_unhealthy_routing_request_count = optional(bool)
    unhealthy_routing_request_count         = optional(number)
    enabled_unhealthy_state_dns             = optional(bool)
    unhealthy_state_dns                     = optional(number)
    enabled_unhealthy_state_routing         = optional(bool)
    unhealthy_state_routing                 = optional(number)

    # User Authentication Metrics
    enabled_elb_auth_error                     = optional(bool)
    elb_auth_error                             = optional(number)
    enabled_elb_auth_failure                   = optional(bool)
    elb_auth_failure                           = optional(number)
    enabled_elb_auth_latency                   = optional(bool)
    elb_auth_latency                           = optional(number)
    enabled_elb_auth_refresh_token_success     = optional(bool)
    elb_auth_refresh_token_success             = optional(number)
    enabled_elb_auth_success                   = optional(bool)
    elb_auth_success                           = optional(number)
    enabled_elb_auth_user_claims_size_exceeded = optional(bool)
    elb_auth_user_claims_size_exceeded         = optional(number)

    # Lambda Function Metrics
    enabled_lambda_internal_error         = optional(bool)
    lambda_internal_error                 = optional(number)
    enabled_lambda_target_processed_bytes = optional(bool)
    lambda_target_processed_bytes         = optional(number)
    enabled_lambda_user_error             = optional(bool)
    lambda_user_error                     = optional(number)

    # Target Optimizer Metrics
    enabled_mitigated_host_count                = optional(bool)
    mitigated_host_count                        = optional(number)
    enabled_target_control_active_channel_count = optional(bool)
    target_control_active_channel_count         = optional(number)
    enabled_target_control_channel_error_count  = optional(bool)
    target_control_channel_error_count          = optional(number)
    enabled_target_control_new_channel_count    = optional(bool)
    target_control_new_channel_count            = optional(number)
    enabled_target_control_processed_bytes      = optional(bool)
    target_control_processed_bytes              = optional(number)
    enabled_target_control_request_count        = optional(bool)
    target_control_request_count                = optional(number)
    enabled_target_control_request_reject_count = optional(bool)
    target_control_request_reject_count         = optional(number)
    enabled_target_control_work_queue_length    = optional(bool)
    target_control_work_queue_length            = optional(number)
    enabled_target_optimizer_anomaly_score      = optional(bool)
    target_optimizer_anomaly_score              = optional(number)
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the LoadBalancer."
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
