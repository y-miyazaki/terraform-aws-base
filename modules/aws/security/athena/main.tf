#--------------------------------------------------------------
# Module: aws/security/athena
# Purpose: Update Athena primary workgroup to enforce SSE_S3 result encryption via local-exec.
# Notes: Uses null_resource with AWS CLI; future improvement: replace with native Terraform resource once available.
#--------------------------------------------------------------
data "aws_region" "current" {}

resource "null_resource" "athena_primary_workgroup_encryptionoption" {
  count = var.is_enabled ? 1 : 0

  triggers = {
    workgroup       = var.workgroup
    output_location = var.output_location
    region          = data.aws_region.current.region
  }

  provisioner "local-exec" {
    command = <<-EOF
      aws athena update-work-group \
        --work-group "${var.workgroup}" \
        --region ${data.aws_region.current.region} \
        --configuration-updates '${jsonencode({
    EnforceWorkGroupConfiguration   = true
    PublishCloudWatchMetricsEnabled = true
    ResultConfigurationUpdates = merge(
      {
        RemoveEncryptionConfiguration = false
        EncryptionConfiguration = {
          EncryptionOption = "SSE_S3"
        }
      },
      var.output_location != null ? { OutputLocation = var.output_location } : {}
    )
})}'
    EOF
}
}
