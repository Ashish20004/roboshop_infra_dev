resource "aws_acm_certificate" "roboshop" {
    domain_name       = "*.${var.domain_name}"
    validation_method = "DNS"

    tags = merge(
    {
        Name = "${var.project}-${var.environment}-${var.domain_name}"
    },
    local.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "roboshop" {
    for_each = {
    for dvo in aws_acm_certificate.roboshop.domain_validation_options : dvo.domain_name => {
        name    = dvo.resource_record_name
        type    = dvo.resource_record_type
        record  = dvo.resource_record_value
    }
    }

    allow_overwrite = true
    name            = each.value.name
    type            = each.value.type
    zone_id         = var.zone_id
    records         = [each.value.record]
    ttl             = 60    

}

resource "aws_acm_certificate_validation" "roboshop" {
    certificate_arn         = aws_acm_certificate.roboshop.arn
    validation_record_fqdns = [for record in aws_route53_record.roboshop : record.fqdn]
} 