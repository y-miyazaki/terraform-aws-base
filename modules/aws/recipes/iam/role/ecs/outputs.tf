output "ecs_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.ecs.arn
}
output "ecs_name" {
  description = "Name of the role."
  value       = aws_iam_role.ecs.name
}
output "ecs_tasks_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.ecs_tasks.arn
}
output "ecs_tasks_name" {
  description = "Name of the role."
  value       = aws_iam_role.ecs_tasks.name
}
output "events_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.events.arn
}
output "events_name" {
  description = "Name of the role."
  value       = aws_iam_role.events.name
}
