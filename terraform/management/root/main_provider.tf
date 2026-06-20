#--------------------------------------------------------------
# Terraform Provider Configuration
# All resources MUST explicitly set region; this provider is a safety fallback only.
#--------------------------------------------------------------
terraform {
  required_version = ">= 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
  }
}

# Default provider — fallback to primary region.
provider "aws" {
  region = var.region.primary
  default_tags {
    tags = var.tags
  }
}
