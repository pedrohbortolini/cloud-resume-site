# Public hosted zone for the custom domain. The domain stays registered at
# Registro.br; only its name servers point here (set by hand at the registrar).
resource "aws_route53_zone" "site" {
  name    = var.domain_name
  comment = "Resume site"
}
