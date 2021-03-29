output "id" {
  description = "Name of the recorder"
  value       = var.is_enabled ? aws_config_configuration_recorder.this[0].id : null
}
