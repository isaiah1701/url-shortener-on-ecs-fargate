terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}


resource "aws_acm_certificate" "this" {


  domain_name       = var.domain_name
  validation_method = "DNS"
   lifecycle {
    create_before_destroy = true
  }
}
resource "cloudflare_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.cloudflare_zone_id   
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for dvo in aws_acm_certificate.this.domain_validation_options : dvo.resource_record_name]
}
