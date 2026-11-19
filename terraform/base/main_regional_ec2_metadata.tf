#--------------------------------------------------------------
# Regional deployment of AWS EC2 Instance Metadata defaults
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to enforce IMDSv2 across regions.

module "aws_security_ec2_metadata" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/ec2_metadata"

  is_enabled = var.security_ec2_metadata.is_enabled
  region     = each.value

  http_endpoint               = var.security_ec2_metadata.http_endpoint
  http_put_response_hop_limit = var.security_ec2_metadata.http_put_response_hop_limit
  http_tokens                 = var.security_ec2_metadata.http_tokens
}
