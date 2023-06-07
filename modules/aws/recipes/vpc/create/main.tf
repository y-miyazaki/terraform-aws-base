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
# Create VPC
# https://www.terraform.io/docs/providers/aws/r/vpc.html
#--------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags                 = merge(local.tags, { "Name" = "${local.name_prefix}-vpc" })
}

#--------------------------------------------------------------
# Create Internet Gateway
# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
#--------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { "Name" = "${local.name_prefix}-igw" })
}

#--------------------------------------------------------------
# Provides an VPC subnet resource.
#--------------------------------------------------------------
# tfsec:ignore:aws-ec2-no-public-ip-subnet
resource "aws_subnet" "igw" {
  count                   = length(var.igw_cidr_block)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.igw_cidr_block[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { "Name" = format("%v-igw-subnet-%d", local.name_prefix, count.index + 1) })
}

#--------------------------------------------------------------
# Create NAT Gateway
# EIPを２つ分作成し、NATも冗長化します。
#--------------------------------------------------------------
resource "aws_eip" "nat" {
  count = length(var.nat_cidr_block)
  vpc   = true
  tags  = merge(local.tags, { "Name" = format("%v-nat-%d", local.name_prefix, count.index + 1) })
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.nat_cidr_block)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.igw.*.id, count.index)
  tags          = merge(local.tags, { "Name" = format("%v-nat-%d", local.name_prefix, count.index + 1) })
}

#--------------------------------------------------------------
# Provides an VPC subnet resource.
#--------------------------------------------------------------
resource "aws_subnet" "nat" {
  count                   = length(var.nat_cidr_block)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.nat_cidr_block[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = false
  tags                    = merge(local.tags, { "Name" = format("%v-nat-subnet-%d", local.name_prefix, count.index + 1) })
}

#--------------------------------------------------------------
# Create Route Table
# Internet Gateway用とNAT Gateway用の２つ分のRoute Tableを作成します。
# https://www.terraform.io/docs/providers/aws/r/route_table.html
#--------------------------------------------------------------
resource "aws_route_table" "private" {
  count  = length(var.nat_cidr_block)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }
  tags = merge(local.tags, { "Name" = format("%v-private-routetable-%d", local.name_prefix, count.index + 1) })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.tags, { "Name" = format("%v-public-routetable-1", local.name_prefix) })
}

#--------------------------------------------------------------
# Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway.
#--------------------------------------------------------------
resource "aws_route_table_association" "nat" {
  count          = length(var.nat_cidr_block)
  subnet_id      = element(aws_subnet.nat.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

#--------------------------------------------------------------
# Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway.
#--------------------------------------------------------------
resource "aws_route_table_association" "igw" {
  count          = length(var.nat_cidr_block)
  subnet_id      = element(aws_subnet.igw.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}
