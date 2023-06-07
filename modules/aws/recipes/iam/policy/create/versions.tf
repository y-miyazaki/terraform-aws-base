#--------------------------------------------------------------
# Terraform Provider
#--------------------------------------------------------------
terraform {
  required_version = "~>1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.67.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">=2.0.0"
    }
  }
}
