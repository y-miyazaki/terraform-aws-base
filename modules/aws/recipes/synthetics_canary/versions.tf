#--------------------------------------------------------------
# Terraform Provider
# https://newreleases.io/project/github/hashicorp/terraform-provider-aws/release/v3.28.0
#--------------------------------------------------------------
terraform {
  required_version = "~>1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.67.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.2.1"
    }
  }
}
