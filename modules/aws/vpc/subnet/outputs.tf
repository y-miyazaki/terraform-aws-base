output "id" {
  description = "The IDs of the subnet"
  value       = [for s in var.aws_subnet : aws_subnet.this[s.cidr_block].id]
}
