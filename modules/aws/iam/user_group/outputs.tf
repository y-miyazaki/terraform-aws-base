output "iam_user_login_profile" {
  value = var.is_enabled ? aws_iam_user_login_profile.this : {}
}
output "iam_access_key" {
  value = var.is_enabled ? aws_iam_access_key.this : {}
}
