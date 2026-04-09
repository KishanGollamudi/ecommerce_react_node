# Define the Terraform and provider requirements for this infrastructure stack.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider used by the root module and all child modules.
# The region stays variable-driven with a production-safe default so environments can override it when needed.
provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}
