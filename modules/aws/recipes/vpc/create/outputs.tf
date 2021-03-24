output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}
output "route_table_private_id" {
  description = "The IDs of the private routing table"
  value       = aws_route_table.private.*.id
}
output "route_table_public_id" {
  description = "The ID of the public routing table"
  value       = aws_route_table.public.id
}
