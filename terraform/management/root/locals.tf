#--------------------------------------------------------------
# Local Variables
#--------------------------------------------------------------
locals {
  # Determine if default region is us-east-1
  # If true, skip creating separate us-east-1 specific resources
  is_default_region_us_east_1 = var.region == "us-east-1"
  is_enabled_us_east_1        = !local.is_default_region_us_east_1 && var.us_east_1.is_enabled
}
