data "external" "list" {
  count = var.is_enabled && var.create_auto_dimensions ? 1 : 0

  program = ["bash", "${path.module}/scripts/list.sh"]
}
