#--------------------------------------------------------------
# Terraform Provider
#--------------------------------------------------------------
terraform {
  required_version = "~>1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.2.1"
    }
  }
}
