#--------------------------------------------------------------
# Athena
#--------------------------------------------------------------
module "athena" {
  source = "../../modules/aws/athena"

  is_enabled = var.athena.is_enabled
  region     = var.region.primary

  cloudfront_log_bucket             = var.athena.cloudfront_log_bucket
  database_bucket                   = var.athena.is_enabled ? module.s3_application_log.s3_bucket_id : ""
  database_comment                  = var.athena.database_comment
  database_encryption_configuration = var.athena.database_encryption_configuration
  # (must be lowercase letters, numbers, or underscore ('_'))
  database_name = var.athena.database_name
  # CloudFront
  enabled_cloudfront = var.athena.enabled_cloudfront
  # SES
  enabled_ses    = var.athena.enabled_ses
  name_prefix    = var.name_prefix
  ses_log_bucket = var.athena.ses_log_bucket
  workgroup_configuration = {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    result_configuration = {
      encryption_configuration = {
        encryption_option = try(var.athena.workgroup_configuration.result_configuration.encryption_configuration.encryption_option, null)
        kms_key           = try(var.athena.workgroup_configuration.result_configuration.encryption_configuration.kms_key, null)
      }
      output_location = var.athena.is_enabled ? format("s3://%s/Logs/Athena/", module.s3_application_log.s3_bucket_id) : null
    }
    requester_pays_enabled = try(var.athena.workgroup_configuration.requester_pays_enabled, false)
  }
  workgroup_description = var.athena.workgroup_description
  workgroup_name        = var.athena.workgroup_name
  workgroup_state       = var.athena.workgroup_state

  tags = var.tags
}
