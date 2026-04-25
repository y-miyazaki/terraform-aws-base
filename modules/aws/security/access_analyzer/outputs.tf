output "id" {
  description = "Analyzer name."
  value       = local.create ? aws_accessanalyzer_analyzer.this[0].id : null
}
