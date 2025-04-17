#--------------------------------------------------------------
# Terraform Provider
#--------------------------------------------------------------
terraform {
  required_version = "~>1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~>2.3.2"
    }
  }
}
