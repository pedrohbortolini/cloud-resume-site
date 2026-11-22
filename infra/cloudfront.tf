# Origin Access Control: CloudFront signs every request to S3 with SigV4,
# and the bucket policy only trusts signed requests from this distribution.
# OAC replaces the legacy Origin Access Identity (OAI).
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = var.project_name
  description                       = "Signed access from CloudFront to the site bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# AWS managed cache policy for static content (long TTLs, gzip and brotli).
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  comment             = var.project_name
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  http_version        = "http2and3"

  # Edge locations in North America and Europe only: the cheapest tier.
  # Visitors elsewhere are still served, just from a farther edge.
  price_class = "PriceClass_100"

  origin {
    origin_id                = "s3-site"
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-site"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # No custom domain yet, so the site uses the default *.cloudfront.net
  # certificate. A custom domain needs an ACM certificate in us-east-1.
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
