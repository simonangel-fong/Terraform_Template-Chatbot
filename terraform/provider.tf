terraform {
  # declare provider and version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }
  }

  backend "s3" {
    bucket = ""
    region = ""
    key    = ""
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
