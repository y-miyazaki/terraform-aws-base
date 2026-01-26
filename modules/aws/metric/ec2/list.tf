data "aws_instances" "this" {
  instance_state_names = [
    "pending",
    "running",
    "stopped",
    "stopping",
  ]
}
