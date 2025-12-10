#--------------------------------------------------------------
# Outputs for auto_discovery_filter internal module
#--------------------------------------------------------------

output "filtered_list" {
  description = "Filtered list after applying include/exclude patterns with null safety"
  value       = local.filtered_list
}

output "safe_manual_dimensions" {
  description = "Manual dimensions with null safety applied"
  value       = local.safe_manual_dimensions
}

output "should_use_auto" {
  description = "Whether to use auto-discovered dimensions (true) or manual (false)"
  value       = var.is_enabled && var.create_auto
}
