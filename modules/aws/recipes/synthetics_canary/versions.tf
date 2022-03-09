#--------------------------------------------------------------
# Terraform Provider
# https://newreleases.io/project/github/hashicorp/terraform-provider-aws/release/v3.28.0
#--------------------------------------------------------------
terraform {
  required_version = ">=0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0.0"
    }
  }
}
