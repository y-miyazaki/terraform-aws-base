output "id" {
  description = "Analyzer name."
  value       = var.is_enabled ? aws_accessanalyzer_analyzer.this[0].id : null
}
