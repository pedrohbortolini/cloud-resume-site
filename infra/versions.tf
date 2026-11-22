terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # State stays local on purpose (see docs). It is gitignored because it
  # holds account details. A remote S3 backend is a planned follow-up.
}

# Credentials come from the environment (AWS_PROFILE with IAM Identity
# Center SSO), never from this file.
provider "aws" {
  region = var.region

  # Applied to every resource that supports tags, so they never drift.
  default_tags {
    tags = {
      Project    = var.project_name
      ManagedBy  = "terraform"
      Repository = "cloud-resume-site"
    }
  }
}
