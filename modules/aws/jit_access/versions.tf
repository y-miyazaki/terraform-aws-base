#--------------------------------------------------------------
# Terraform Provider
#--------------------------------------------------------------
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.53.0, < 7.0.0" # aws_api_gateway_rest_api security_policy / endpoint_access_mode
    }
  }
}
