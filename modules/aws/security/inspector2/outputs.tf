output "account_id" {
  description = "The account ID where Inspector2 is enabled"
  value       = try(data.aws_caller_identity.current.account_id, null)
}
