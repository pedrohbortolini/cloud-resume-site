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

  # The custom domain and its www name; both serve the same site.
  aliases = [var.domain_name, "www.${var.domain_name}"]

  # Uses the validated certificate, so the distribution only switches over once
  # ACM has issued it. SNI is free (a dedicated IP costs $600/month).
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
