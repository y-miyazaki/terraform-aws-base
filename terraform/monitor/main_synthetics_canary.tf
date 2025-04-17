#--------------------------------------------------------------
# For Synthetics Canary
#--------------------------------------------------------------
locals {
  synthetics_canary_s3_bucket_arn = var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_synthetics_canary.execution_role_arn == null ? module.s3_application_log.s3_bucket_arn : null
}
#--------------------------------------------------------------
#️ Provides a Synthetics Canary resource.
#--------------------------------------------------------------
module "aws_synthetics_canary_heartbeat" {
  source     = "../../modules/aws/synthetics_canary"
  is_enabled = lookup(var.metric_synthetics_canary_heartbeat, "is_enabled", true)
  aws_iam_role = merge(var.metric_synthetics_canary_heartbeat.synthetics_canary.aws_iam_role, {
    name = format("%s%s", var.name_prefix, var.metric_synthetics_canary_heartbeat.synthetics_canary.aws_iam_role.name)
  })
  account_id    = data.aws_caller_identity.current.account_id
  region        = var.region
  s3_bucket_arn = local.synthetics_canary_s3_bucket_arn
  aws_iam_policy = merge(var.metric_synthetics_canary_heartbeat.synthetics_canary.aws_iam_policy, {
    name = format("%s%s", var.name_prefix, var.metric_synthetics_canary_heartbeat.synthetics_canary.aws_iam_policy.name)
  })
  aws_synthetics_canary = merge(var.metric_synthetics_canary_heartbeat.synthetics_canary.aws_synthetics_canary, {
    artifact_s3_location = var.metric_synthetics_canary_heartbeat.synthetics_canary.aws_synthetics_canary.artifact_s3_location == null ? "s3://${module.s3_application_log.s3_bucket_id}/" : var.metric_synthetics_canary_heartbeat.synthetics_canary.aws_synthetics_canaryartifact_s3_location
    handler              = "index.handler"
    name                 = format("%s%s", var.name_prefix, var.metric_synthetics_canary_heartbeat.synthetics_canary.aws_synthetics_canary.name)
    # (Optional) ZIP file that contains the script, if you input your canary script directly into the canary instead of referring to an S3 location. It can be up to 5 MB. Conflicts with s3_bucket, s3_key, and s3_version.
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries_WritingCanary_Nodejs.html#CloudWatch_Synthetics_Canaries_package
    # cd /workspace/nodejs/heartbeat; zip -r /workspace/lambda/outputs/nodejs_heartbeat.zip ./
    zip_file = "../../lambda/outputs/nodejs_heartbeat.zip"
    }
  )
  tags = var.tags
}
module "aws_synthetics_canary_linkcheck" {
  source     = "../../modules/aws/synthetics_canary"
  is_enabled = lookup(var.metric_synthetics_canary_linkcheck, "is_enabled", true)
  aws_iam_role = merge(var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_iam_role, {
    name = format("%s%s", var.name_prefix, var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_iam_role.name)
  })
  account_id    = data.aws_caller_identity.current.account_id
  region        = var.region
  s3_bucket_arn = local.synthetics_canary_s3_bucket_arn
  aws_iam_policy = merge(var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_iam_policy, {
    name = format("%s%s", var.name_prefix, var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_iam_policy.name)
  })
  aws_synthetics_canary = merge(var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_synthetics_canary, {
    artifact_s3_location = var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_synthetics_canary.artifact_s3_location == null ? "s3://${module.s3_application_log.s3_bucket_id}/" : var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_synthetics_canaryartifact_s3_location
    handler              = "index.handler"
    name                 = format("%s%s", var.name_prefix, var.metric_synthetics_canary_linkcheck.synthetics_canary.aws_synthetics_canary.name)
    # (Optional) ZIP file that contains the script, if you input your canary script directly into the canary instead of referring to an S3 location. It can be up to 5 MB. Conflicts with s3_bucket, s3_key, and s3_version.
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries_WritingCanary_Nodejs.html#CloudWatch_Synthetics_Canaries_package
    # cd /workspace/nodejs/linkcheck; zip -r /workspace/lambda/outputs/nodejs_linkcheck.zip ./
    zip_file = "../../lambda/outputs/nodejs_linkcheck.zip"
    }
  )
  tags = var.tags
}
