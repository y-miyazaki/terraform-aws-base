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
variable "resourcegroups_group" {
  type = any
}
variable "budgets" {
  type = any
}
variable "compute_optimizer" {
  type = any
}
variable "health" {
  type = any
}
variable "trusted_advisor" {
  type = any
}
variable "iam" {
  type = any
}
variable "common_lambda" {
  type = any
}
variable "common_log" {
  type = any
}
# security
variable "security_access_analyzer" {
  type = any
}
variable "security_cloudtrail" {
  type = any
}
variable "security_config" {
  type = any
}
variable "security_config_us_east_1" {
  type = any
}
variable "security_default_vpc" {
  type = any
}
variable "security_ebs" {
  type = any
}
variable "security_guardduty" {
  type = any
}
variable "security_iam" {
  type = any
}
variable "security_s3" {
  type = any
}
variable "security_securityhub" {
  type = any
}
