terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  access_key = "AKIA5O7Y3MSPQ5PDD54U"
  secret_key = "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"
  region     = "us-east-1"
}