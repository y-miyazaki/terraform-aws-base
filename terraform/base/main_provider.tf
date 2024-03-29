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
  }
  #   backend "s3" {
  #   }
}

#--------------------------------------------------------------
# AWS Provider
# access key and secret key should not use.
#--------------------------------------------------------------
provider "aws" {
  # TODO: need to change profile.
  profile = "default"
  # TODO: need to change region.
  region = "ap-northeast-1"
  #   default_tags {
  #     tags = var.tags
  #   }
}
# Need to add aws provider(us-east-1) for CloudFront Metric.
provider "aws" {
  profile = "default"
  region  = "us-east-1"
  alias   = "us-east-1"
  #   default_tags {
  #     tags = var.tags
  #   }
}
