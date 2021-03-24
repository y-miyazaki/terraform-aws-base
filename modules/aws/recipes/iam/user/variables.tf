variable "iam_user_users" {
  default = []
}
variable "iam_user_group_administrator" {
  default = []
}
variable "iam_user_group_developer" {
  default = []
}
variable "iam_user_group_operator" {
  default = []
}
variable "name_prefix" {
  type    = string
  default = null
}
