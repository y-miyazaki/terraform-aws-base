# Terraform provider and required versions for module
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}
