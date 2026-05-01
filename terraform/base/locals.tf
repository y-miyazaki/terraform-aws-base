#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  # Determine if default region is us-east-1
  # If true, skip creating separate us-east-1 specific resources
  is_default_region_us_east_1 = var.region == "us-east-1"
  is_enabled_us_east_1        = !local.is_default_region_us_east_1 && var.us_east_1.is_enabled

  # Derive is_control_tower_enabled from the control_tower object.
  # Defaults to false when control_tower is not set.
  is_control_tower_enabled = var.control_tower != null ? var.control_tower.is_enabled : false
  control_tower_managed_services = {
    access_analyzer = coalesce(try(var.control_tower.managed_services.access_analyzer, null), local.is_control_tower_enabled)
    cloudtrail      = coalesce(try(var.control_tower.managed_services.cloudtrail, null), local.is_control_tower_enabled)
    config          = coalesce(try(var.control_tower.managed_services.config, null), local.is_control_tower_enabled)
    guardduty       = coalesce(try(var.control_tower.managed_services.guardduty, null), local.is_control_tower_enabled)
    inspector2      = coalesce(try(var.control_tower.managed_services.inspector2, null), local.is_control_tower_enabled)
    macie           = coalesce(try(var.control_tower.managed_services.macie, null), local.is_control_tower_enabled)
    securityhub     = coalesce(try(var.control_tower.managed_services.securityhub, null), local.is_control_tower_enabled)
  }
}
