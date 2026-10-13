data "aws_instances" "this" {
  region = local.region

  instance_state_names = [
    "pending",
    "running",
    "stopped",
    "stopping",
  ]
}
