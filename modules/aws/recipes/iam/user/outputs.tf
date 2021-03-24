output "name_administrator" {
  description = "The group's name."
  value       = aws_iam_group.administrator.name
}
output "name_developer" {
  description = "The group's name."
  value       = aws_iam_group.developer.name
}
output "name_operator" {
  description = "The group's name."
  value       = aws_iam_group.operator.name
}
