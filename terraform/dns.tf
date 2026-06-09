# Primary domain A record (e.g. regtest.unicycling-software.com or
# reg.unicycling-software.com)
resource "aws_route53_record" "app" {
  zone_id         = var.zone_id
  name            = var.domain
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

# Wildcard record routing all tenant subdomains (*.regtest.unicycling-software.com)
# to the ALB.
# This allows tenants at myconvention.regtest.unicycling-software.com to resolve to the
# production ALB without a per-tenant DNS record.
resource "aws_route53_record" "wildcard" {
  count           = var.wildcard_domain != null ? 1 : 0
  zone_id         = var.zone_id
  name            = var.wildcard_domain
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
