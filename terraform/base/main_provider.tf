#--------------------------------------------------------------
# Terraform Provider
#--------------------------------------------------------------
terraform {
  required_version = "~>1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.98.0"
    }
  }
  backend "s3" {
  }
}

#--------------------------------------------------------------
# AWS Provider
# access key and secret key should not use.
#--------------------------------------------------------------
provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}
# Need to add aws provider(us-east-1) for CloudFront Metric.
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  default_tags {
    tags = var.tags
  }
}
