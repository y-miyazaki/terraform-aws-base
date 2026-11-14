#--------------------------------------------------------------
# Synthetics Canary Configuration
#--------------------------------------------------------------
locals {
  # Function names built from nodejs/synthetics_canary_<name>/index.js
  synthetics_canary_functions = toset(["heartbeat", "linkcheck"])
}

#--------------------------------------------------------------
# Provides the Synthetics Canary packages (index.js at the zip root)
# Written to builds/ (gitignored); do not commit built zip files.
#--------------------------------------------------------------
data "archive_file" "synthetics_canary" {
  for_each = local.synthetics_canary_functions

  output_path = "${path.module}/builds/nodejs_synthetics_canary_${each.key}.zip"
  source_file = "${path.module}/../../nodejs/synthetics_canary_${each.key}/index.js"
  type        = "zip"
}

#--------------------------------------------------------------
# Provides Synthetics Canary resources
#--------------------------------------------------------------
module "aws_synthetics_canary" {
  for_each = var.metric_synthetics_canary.functions

  source = "../../modules/aws/synthetics_canary"

  is_enabled = each.value.is_enabled
  region     = var.region.primary

  account_id = data.aws_caller_identity.current.account_id
  aws_iam_policy = {
    name        = format("%smonitor-synthetics-canary-%s-policy", var.name_prefix, each.key)
    description = format("IAM policy for Synthetics Canary(%s)", each.key)
    path        = "/"
  }
  aws_iam_role = {
    name        = format("%smonitor-synthetics-canary-%s-role", var.name_prefix, each.key)
    description = format("IAM role for Synthetics Canary(%s)", each.key)
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
    # Updated package structure for syn-nodejs-puppeteer-11.0+: index.js at root level
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries_WritingCanary_Nodejs.html#CloudWatch_Synthetics_Canaries_package
    zip_file = data.archive_file.synthetics_canary[each.key].output_path
    }
  )
  s3_bucket_arn = module.s3_application_log.s3_bucket_arn

  tags = var.tags
}
