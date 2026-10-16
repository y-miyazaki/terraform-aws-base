#--------------------------------------------------------------
# Terraform Provider Configuration
# All resources MUST explicitly set region; this provider is a safety fallback only.
#--------------------------------------------------------------
terraform {
  required_version = ">= 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0, < 7.0.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.104.0, < 2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0, < 1.0.0"
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

# AWS Cloud Control provider — used for AWS DevOps Agent (not available in hashicorp/aws).
provider "awscc" {
  region = var.region.primary
}
