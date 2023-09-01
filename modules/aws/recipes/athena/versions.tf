#--------------------------------------------------------------
# Terraform Provider
#--------------------------------------------------------------
terraform {
  required_version = "~>1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.15.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~>2.2.0"
    }
  }
}
