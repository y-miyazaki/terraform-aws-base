resource "null_resource" "athena_primary_workgroup_encryptionoption" {
  count = var.is_enabled ? 1 : 0
  triggers = {
    workgroup = var.workgroup
  }

  provisioner "local-exec" {
    command = <<-EOF
      aws athena update-work-group \
        --work-group "primary" \
        --configuration-updates '{
        "EnforceWorkGroupConfiguration": false,
        "ResultConfigurationUpdates": {
          "RemoveEncryptionConfiguration": false,
          "EncryptionConfiguration": {
            "EncryptionOption": "SSE_S3"
          }
        }
      }'
    EOF
  }
}
