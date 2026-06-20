#--------------------------------------------------------------
# Regional deployment of AWS EC2 Instance Metadata defaults
# This module is deployed to each region in var.region.targets
# to enforce IMDSv2 across regions.
#--------------------------------------------------------------
module "aws_security_ec2_metadata" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/ec2_metadata"

  is_enabled = try(var.security_ec2_metadata.is_enabled, true)
  region     = each.value

  http_endpoint               = try(var.security_ec2_metadata.http_endpoint, "enabled")
  http_tokens                 = try(var.security_ec2_metadata.http_tokens, "required")
  http_put_response_hop_limit = try(var.security_ec2_metadata.http_put_response_hop_limit, 1)
}
