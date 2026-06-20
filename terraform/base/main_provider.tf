# Terraform Provider Configuration
# AWS Provider v6+ supports region attribute on resources
# All resources MUST explicitly set region; this provider is a safety fallback only.

terraform {
  required_version = ">= 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    # Configuration provided via backend config file or CLI flags
  }
}

# Default provider — fallback to primary region.
# All resources should explicitly set region via var.region.global or var.region.targets.
provider "aws" {
  region = var.region.primary
  default_tags {
    tags = var.tags
  }
}
