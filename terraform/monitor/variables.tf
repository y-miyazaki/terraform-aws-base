variable "deploy_user" {
  type = string
}
variable "tags" {
  type = map(any)
}
variable "name_prefix" {
  type = string
}
variable "region" {
  type = string
}
variable "common_lambda" {
  type = any
}
variable "common_log" {
  type = any
}
variable "delivery_log" {
  type = any
}
variable "delivery_log_us_east_1" {
  type = any
}
variable "metric_log_application" {
  type        = any
  description = "CloudWatch Logs (Application) resources on AWS"
}
# TODO: ex
# variable "metric_log_step_functions" {
#   type        = any
#   description = "CloudWatch Logs (Step Functrions) resources on AWS"
# }
variable "metric_log_waf" {
  type        = any
  description = "CloudWatch Logs (WAF) resources on AWS"
}
variable "metric_log_mysql_slowquery" {
  type        = any
  description = "CloudWatch Logs (MySQL slow query) resources on AWS"
}
variable "metric_log_postgresql" {
  type        = any
  description = "CloudWatch Logs (PostgreSQL) resources on AWS"
}
variable "metric_log_postgresql_slowquery" {
  type        = any
  description = "CloudWatch Logs (PostgreSQL) resources on AWS"
}
variable "metric_resource_alb" {
  type        = any
  description = "CloudWatch metric resource(ALB) resources on AWS"
}
variable "metric_resource_api_gateway" {
  type        = any
  description = "CloudWatch metric resource(API Gateway) resources on AWS"
}
variable "metric_resource_cloudfront" {
  type        = any
  description = "CloudWatch metric resource(CloudFront) resources on AWS"
}
variable "metric_resource_ec2" {
  type        = any
  description = "CloudWatch metric resource(EC2) resources on AWS"
}
variable "metric_resource_ecs_container_insights" {
  type        = any
  description = "CloudWatch metric resource(ECS/ContainerInsights) resources on AWS"
}
variable "metric_resource_elasticache" {
  type        = any
  description = "CloudWatch event(ElastiCache) resources on AWS"
}
variable "metric_resource_eventbridge_scheduler" {
  type        = any
  description = "CloudWatch event(EventBridge Scheduler) resources on AWS"
}
variable "metric_resource_lambda" {
  type        = any
  description = "CloudWatch event(Lambda) resources on AWS"
}
variable "metric_resource_rds_cluster" {
  type        = any
  description = "CloudWatch event(RDS) resources on AWS"
}
variable "metric_resource_redshift" {
  type        = any
  description = "CloudWatch event(Redshift) resources on AWS"
}
variable "metric_resource_ses" {
  type        = any
  description = "CloudWatch event(SES) resources on AWS"
}
variable "metric_resource_sqs_dlq" {
  type        = any
  description = "CloudWatch event(SQS(DLQ)) resources on AWS"
}
variable "cloudwatch_event_ec2" {
  type        = any
  description = "CloudWatch event(EC2) resources on AWS"
}
variable "metric_synthetics_canary_heartbeat" {
  type        = any
  description = "Synthetics canary heartbeat resources on AWS"
}
variable "metric_synthetics_canary_linkcheck" {
  type        = any
  description = "Synthetics canary linkcheck resources on AWS"
}
variable "athena" {
  type        = any
  description = "Athena resources on AWS"
}
variable "report_csp" {
  type        = any
  description = "API Gateway resources on AWS"
}
variable "eventbridge" {
  type        = any
  description = "EventBridge resources on AWS"
}
