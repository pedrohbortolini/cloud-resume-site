# Private bucket that holds the static site files.
# bucket_prefix lets AWS append a unique suffix, so the name is globally
# unique without hardcoding anything account specific in a public repo.
resource "aws_s3_bucket" "site" {
  bucket_prefix = "${var.project_name}-"
}

# Blocks every form of public access. Visitors never reach the bucket
# directly; only CloudFront can read it (see the policy below).
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Grants read access to the CloudFront service, but only for requests
# coming from this specific distribution (AWS:SourceArn). That condition
# is what stops another CloudFront distribution from reading the bucket.
data "aws_iam_policy_document" "site" {
  statement {
    sid       = "AllowCloudFrontRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json

  # Apply the public access block first so the bucket is never briefly
  # exposed while the policy is being attached.
  depends_on = [aws_s3_bucket_public_access_block.site]
}
