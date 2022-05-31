#--------------------------------------------------------------
# For Synthetics Canary
#--------------------------------------------------------------
locals {
  aws_synthetics_canary = merge(var.synthetics_canary.aws_synthetics_canary, {
    artifact_s3_location = var.synthetics_canary.aws_synthetics_canary.artifact_s3_location == null ? "s3://${module.s3_application_log.s3_bucket_id}/" : var.synthetics_canary.aws_synthetics_canaryartifact_s3_location
    name                 = "${var.name_prefix}${var.synthetics_canary.aws_synthetics_canary.name}"
    }
  )
  aws_iam_role_synthetics_canary = merge(var.synthetics_canary.aws_iam_role, {
    name = "${var.name_prefix}${var.synthetics_canary.aws_iam_role.name}"
  })
  aws_iam_policy_synthetics_canary = merge(var.synthetics_canary.aws_iam_policy, {
    name = "${var.name_prefix}${var.synthetics_canary.aws_iam_policy.name}"
  })
  s3_bucket_arn = var.synthetics_canary.aws_synthetics_canary.execution_role_arn == null ? module.s3_application_log.s3_bucket_arn : null
}
#--------------------------------------------------------------
#️ Provides a Synthetics Canary resource.
#--------------------------------------------------------------
module "aws_recipes_synthetics_canary" {
  source                = "../../modules/aws/recipes/synthetics_canary"
  is_enabled            = lookup(var.synthetics_canary, "is_enabled", true)
  aws_iam_role          = local.aws_iam_role_synthetics_canary
  account_id            = data.aws_caller_identity.current.account_id
  region                = var.region
  s3_bucket_arn         = local.s3_bucket_arn
  aws_iam_policy        = local.aws_iam_policy_synthetics_canary
  aws_synthetics_canary = local.aws_synthetics_canary
  tags                  = var.tags
}
