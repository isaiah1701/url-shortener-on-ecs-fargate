resource "aws_acm_certificate" "this" {


  domain_name       = var.domain_name
  validation_method = var.validation_method
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for dvo in aws_acm_certificate.this.domain_validation_options : dvo.resource_record_name]
}