# Public hosted zone for the custom domain. The domain stays registered at
# Registro.br; only its name servers point here (set by hand at the registrar).
resource "aws_route53_zone" "site" {
  name    = var.domain_name
  comment = "Resume site"
}

# Apex and www point at CloudFront. Alias records are free to query and follow
# the distribution's addresses; AAAA serves IPv6 visitors.
locals {
  site_records = {
    for pair in setproduct([var.domain_name, "www.${var.domain_name}"], ["A", "AAAA"]) :
    "${pair[0]}-${pair[1]}" => { name = pair[0], type = pair[1] }
  }
}

resource "aws_route53_record" "site" {
  for_each = local.site_records

  zone_id = aws_route53_zone.site.zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
