#--------------------------------------------------------------
# Synthetics Canary Configuration
#--------------------------------------------------------------
locals {
  # Map of function names to their ZIP file paths
  synthetics_canary_zip_files = {
    heartbeat = "../../lambda/outputs/nodejs_synthetics_canary_heartbeat.zip"
    linkcheck = "../../lambda/outputs/nodejs_synthetics_canary_linkcheck.zip"
  }
}

#--------------------------------------------------------------
# Provides Synthetics Canary resources
#--------------------------------------------------------------
module "aws_synthetics_canary" {
  for_each = var.metric_synthetics_canary.functions

  source     = "../../modules/aws/synthetics_canary"
  is_enabled = each.value.is_enabled

  account_id = data.aws_caller_identity.current.account_id
  aws_iam_role = {
    name        = format("%smonitor-synthetics-canary-%s-role", var.name_prefix, each.key)
    description = format("IAM role for Synthetics Canary(%s)", each.key)
    path        = "/"
  }
  aws_iam_policy = {
    name        = format("%smonitor-synthetics-canary-%s-policy", var.name_prefix, each.key)
    description = format("IAM policy for Synthetics Canary(%s)", each.key)
    path        = "/"
  }
  aws_synthetics_canary = merge(each.value.aws_synthetics_canary, {
    # Fixed S3 location using application log bucket
    artifact_s3_location = "s3://${module.s3_application_log.s3_bucket_id}/Logs/"
    handler              = "index.handler"
    name                 = format("%s%s", var.name_prefix, each.key)
    # Configuration block for individual canary runs. Detailed below.
    run_config = [
      {
        timeout_in_seconds = 60
        memory_in_mb       = 960
        active_tracing     = false
      }
    ]
    runtime_version = "syn-nodejs-puppeteer-11.0"
    # ZIP file path based on function name (heartbeat or linkcheck)
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries_WritingCanary_Nodejs.html#CloudWatch_Synthetics_Canaries_package
    # cd /workspace/nodejs/synthetics_canary_heartbeat; zip -r /workspace/lambda/outputs/nodejs_synthetics_canary_heartbeat.zip ./
    # cd /workspace/nodejs/synthetics_canary_linkcheck; zip -r /workspace/lambda/outputs/nodejs_synthetics_canary_linkcheck.zip ./
    zip_file = local.synthetics_canary_zip_files[each.key]
    }
  )
  region        = var.region
  s3_bucket_arn = module.s3_application_log.s3_bucket_arn

  tags = var.tags
}
