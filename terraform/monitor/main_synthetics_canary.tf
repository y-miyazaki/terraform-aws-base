#--------------------------------------------------------------
# For Synthetics Canary
#--------------------------------------------------------------
locals {
  tmp_aws_synthetics_canary = var.synthetics_canary.aws_synthetics_canary
  aws_synthetics_canary = merge(local.tmp_aws_synthetics_canary, {
    artifact_s3_location = var.synthetics_canary.aws_synthetics_canary.artifact_s3_location == null ? "s3://${module.aws_recipes_s3_bucket_log_application.id}/" : var.synthetics_canary.aws_synthetics_canaryartifact_s3_location
    }
  )
  s3_bucket_arn = var.synthetics_canary.aws_synthetics_canary.execution_role_arn == null ? module.aws_recipes_s3_bucket_log_application.arn : null
}
#--------------------------------------------------------------
#️ Provides a Synthetics Canary resource.
#--------------------------------------------------------------
module "aws_recipes_synthetics_canary" {
  source                = "../../modules/aws/recipes/synthetics_canary"
  is_enabled            = lookup(var.synthetics_canary, "is_enabled", true)
  aws_synthetics_canary = local.aws_synthetics_canary
  account_id            = data.aws_caller_identity.current.account_id
  region                = var.region
  s3_bucket_arn         = local.s3_bucket_arn
  tags                  = var.tags
}
