data "aws_acm_certificate" "issued" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_route53_record" "root" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}