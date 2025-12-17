#--------------------------------------------------------------
# Outputs for metric_helper internal module
#--------------------------------------------------------------

output "list" {
  description = "Map of resources for for_each usage. Key is dimension value, value contains 'name' and 'dimensions'."
  value       = local.list
}

output "effective_thresholds" {
  description = "Map of resource name to effective threshold (base merged with overrides). Key matches list keys."
  value       = local.effective_thresholds
}

output "filtered_list" {
  description = "Filtered list after applying include/exclude patterns with null safety (for backward compatibility)"
  value       = local.filtered_list
}

output "safe_manual_dimensions" {
  description = "Manual dimensions with null safety applied (for backward compatibility)"
  value       = local.safe_manual_dimensions
}

output "should_use_auto" {
  description = "Whether to use auto-discovered dimensions (true) or manual (false)"
  value       = var.is_enabled && var.create_auto
}
