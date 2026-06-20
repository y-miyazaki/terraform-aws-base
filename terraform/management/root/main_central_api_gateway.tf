#--------------------------------------------------------------
# API Gateway Account Settings
# Singleton: one per AWS account.
# Required for REST API CloudWatch Logs access logging.
#--------------------------------------------------------------
module "api_gateway_account" {
  source = "../../../modules/aws/api_gateway_account"

  region = var.region.primary

  name_prefix = var.name_prefix

  tags = var.tags
}
