terraform {
  # declare provider and version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
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

# Configure the cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}