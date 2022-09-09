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
variable "metric_log_application" {
  type = any
}
variable "metric_log_postgres" {
  type = any
}
variable "metric_resource_alb" {
  type = any
}
variable "metric_resource_api_gateway" {
  type = any
}
variable "metric_resource_cloudfront" {
  type = any
}
variable "metric_resource_ec2" {
  type = any
}
variable "metric_resource_elasticache" {
  type = any
}
variable "metric_resource_lambda" {
  type = any
}
variable "metric_resource_rds" {
  type = any
}
variable "metric_resource_ses" {
  type = any
}
variable "metric_synthetics_canary" {
  type = any
}
variable "cloudwatch_event_ec2" {
  type = any
}
variable "synthetics_canary" {
  type = any
}
