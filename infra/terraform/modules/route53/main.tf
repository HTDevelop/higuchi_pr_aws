resource "aws_route53_zone" "this" {
  name = "${var.sub_domain_name}.${var.domain_name}"
}

resource "aws_route53_record" "work_alias" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "${var.sub_domain_name}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}
