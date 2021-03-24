output "id" {
  description = "The IDs of the subnet"
  value       = aws_subnet.this.*.id
}
