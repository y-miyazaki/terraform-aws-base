output "name" {
  description = "Name of the canary"
  value       = var.is_enabled ? aws_synthetics_canary.this[*].name : []
}
