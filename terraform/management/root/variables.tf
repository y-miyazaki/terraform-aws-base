variable "tags" {
  type = map(any)
}
variable "name_prefix" {
  type = string
}
variable "region" {
  type = string
}
variable "cloudwatch_log_group_retention_in_days" {
  type = number
}
variable "oidc_github" {
  type = any
}
variable "common_lambda" {
  type = any
}
# variable "organizations_policy" {
#   type = any
# }
variable "security_cloudtrail" {
  type = any
}
