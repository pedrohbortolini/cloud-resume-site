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
  value       = "https://${var.domain_name}"
}

output "cloudfront_url" {
  description = "Default CloudFront address, still reachable."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "name_servers" {
  description = "Set these as the DNS servers of the domain at Registro.br."
  value       = aws_route53_zone.site.name_servers
}
