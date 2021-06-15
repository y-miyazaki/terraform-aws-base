#--------------------------------------------------------------
# For Compute
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an Compute Optimizer.
#--------------------------------------------------------------
resource "null_resource" "this" {
  count = var.is_enabled ? 1 : 0
  provisioner "local-exec" {
    # https://docs.aws.amazon.com/compute-optimizer/latest/ug/getting-started.html
    command = "aws compute-optimizer update-enrollment-status --status Active"
  }
  provisioner "local-exec" {
    when = destroy
    # https://docs.aws.amazon.com/compute-optimizer/latest/ug/getting-started.html
    command = "aws compute-optimizer update-enrollment-status --status Inactive"
  }
}
