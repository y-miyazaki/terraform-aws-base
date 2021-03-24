output "id" {
  description = "The ID of the VPC endpoint."
  value       = aws_vpc_endpoint.this.id
}
output "dns_entry" {
  description = "The DNS entries for the VPC Endpoint. Applicable for endpoints of type Interface. DNS blocks are documented below."
  value       = aws_vpc_endpoint.this.dns_entry
}
