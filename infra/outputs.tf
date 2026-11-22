output "bucket_name" {
  description = "Target for the manual deploy: aws s3 sync site/ s3://<bucket_name> --delete"
  value       = aws_s3_bucket.site.bucket
}

output "distribution_id" {
  description = "Used to invalidate the cache after a deploy."
  value       = aws_cloudfront_distribution.site.id
}

output "site_url" {
  description = "Public URL of the site."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}
