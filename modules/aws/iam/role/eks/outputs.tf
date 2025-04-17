output "eks_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.eks.arn
}
output "eks_name" {
  description = "Name of the role."
  value       = aws_iam_role.eks.name
}
output "node_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.eks_worker_node.arn
}
output "node_name" {
  description = "Name of the role."
  value       = aws_iam_role.eks_worker_node.name
}
# output "node_external_dns_arn" {
#   value = aws_iam_role.eks_worker_node_external_dns.arn
# }
