#--------------------------------------------------------------
# Module: aws/compute_optimizer
# Purpose: Enable or disable AWS Compute Optimizer enrollment using local-exec provisioners.
# Notes: Uses local-exec to call AWS CLI; future improvement could replace imperative actions with native resources if exposed.
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
