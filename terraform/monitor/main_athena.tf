#--------------------------------------------------------------
# Athena
#--------------------------------------------------------------
module "athena" {
  count          = var.athena.is_enabled ? 1 : 0
  source         = "../../modules/aws/recipes/athena"
  name_prefix    = var.name_prefix
  workgroup_name = var.athena.workgroup_name
  workgroup_configuration = {
    enforce_workgroup_configuration    = lookup(var.athena.workgroup_configuration, "enforce_workgroup_configuration", null)
    publish_cloudwatch_metrics_enabled = lookup(var.athena.workgroup_configuration, "publish_cloudwatch_metrics_enabled", null)
    result_configuration = {
      encryption_configuration = {
        encryption_option = lookup(var.athena.workgroup_configuration.result_configuration.encryption_configuration, "encryption_option", null)
        kms_key           = lookup(var.athena.workgroup_configuration.result_configuration.encryption_configuration, "kms_key", null)
      }
      output_location = format("s3://%s/Logs/Athena/", module.s3_application_log.s3_bucket_id)
    }
    requester_pays_enabled = lookup(var.athena.workgroup_configuration, "requester_pays_enabled", false)
  }
  workgroup_state       = var.athena.workgroup_state
  workgroup_description = var.athena.workgroup_description
  database_bucket       = module.s3_application_log.s3_bucket_id
  # (must be lowercase letters, numbers, or underscore ('_'))
  database_name                     = var.athena.database_name
  database_comment                  = var.athena.database_comment
  database_encryption_configuration = var.athena.database_encryption_configuration

  # CloudFront
  enabled_cloudfront    = var.athena.enabled_cloudfront
  cloudfront_log_bucket = var.athena.cloudfront_log_bucket

  # SES
  enabled_ses    = var.athena.enabled_ses
  ses_log_bucket = var.athena.ses_log_bucket

  tags = var.tags
}
