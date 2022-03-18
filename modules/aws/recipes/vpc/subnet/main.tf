#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  name_prefix = trimsuffix(var.name_prefix, "-")
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an VPC subnet resource.
#--------------------------------------------------------------
resource "aws_subnet" "this" {
  count                   = length(var.aws_subnet)
  availability_zone       = lookup(var.aws_subnet[count.index], "availability_zone")
  cidr_block              = lookup(var.aws_subnet[count.index], "cidr_block")
  map_public_ip_on_launch = lookup(var.aws_subnet[count.index], "map_public_ip_on_launch", false)
  outpost_arn             = lookup(var.aws_subnet[count.index], "outpost_arn", null)
  vpc_id                  = lookup(var.aws_subnet[count.index], "vpc_id", null)
  tags                    = merge(local.tags, { "Name" = format("%v-subnet-%d", local.name_prefix, count.index + 1) })
}

#--------------------------------------------------------------
# Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway.
#--------------------------------------------------------------
resource "aws_route_table_association" "this" {
  count          = length(var.aws_subnet)
  subnet_id      = element(aws_subnet.this.*.id, count.index)
  route_table_id = lookup(var.aws_route_table_association, "route_table_id")
}
