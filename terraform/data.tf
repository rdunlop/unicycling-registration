data "aws_route53_zone" "main" {
  zone_id = var.zone_id
}

data "aws_caller_identity" "current" {}
