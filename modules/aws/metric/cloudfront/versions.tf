#--------------------------------------------------------------
# Terraform Provider
#--------------------------------------------------------------
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0, < 7.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.4.0, < 2.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.3.0, < 3.4.0"
    }
  }
}
