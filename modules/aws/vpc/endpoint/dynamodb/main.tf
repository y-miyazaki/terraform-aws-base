#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides a VPC Endpoint resource.
#--------------------------------------------------------------
resource "aws_vpc_endpoint" "this" {
  service_name        = "com.amazonaws.${var.region}.dynamodb"
  vpc_id              = var.vpc_id
  auto_accept         = var.auto_accept
  policy              = var.policy
  route_table_ids     = var.route_table_ids
  private_dns_enabled = var.private_dns_enabled
  #  subnet_ids          = var.subnet_ids
  #  security_group_ids  = var.security_group_ids
  tags              = local.tags
  vpc_endpoint_type = "Gateway"
}
