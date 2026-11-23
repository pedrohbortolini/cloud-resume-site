# Bootstrap: the S3 bucket that holds the remote state of ../ (the site).
# It keeps its own state locally on purpose: a backend cannot live in the bucket
# it creates. If this local state is lost, the bucket keeps working; it can be
# brought back under management with `terraform import`.

terraform {
  required_version = ">= 1.10" # native S3 locking (use_lockfile) needs 1.10+
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project    = "cloud-resume-site"
      ManagedBy  = "terraform"
      Repository = "cloud-resume-site"
      Purpose    = "terraform-state"
    }
  }
}

resource "aws_s3_bucket" "state" {
  # Random suffix keeps the name globally unique without exposing the account ID.
  bucket_prefix = "cloud-resume-tfstate-"

  # Losing this bucket means losing the record of every resource in the site.
  lifecycle {
    prevent_destroy = true
  }
}

# Every state write becomes a new object version, so a bad write can be rolled back.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# State files can contain sensitive values: encrypt at rest (SSE-S3, no KMS cost).
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Old state versions are only for recovery; drop them after 90 days to keep the bucket tidy.
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Refuse any request that is not over TLS.
data "aws_iam_policy_document" "state" {
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket     = aws_s3_bucket.state.id
  policy     = data.aws_iam_policy_document.state.json
  depends_on = [aws_s3_bucket_public_access_block.state]
}

output "state_bucket" {
  description = "Goes into ../backend.hcl as the bucket value."
  value       = aws_s3_bucket.state.bucket
}
