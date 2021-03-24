output "arn" {
  description = "The ARN assigned by AWS for this resource group."
  value       = aws_resourcegroups_group.this.arn
}
