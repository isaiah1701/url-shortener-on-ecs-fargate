output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "domain_name" {
  description = "Domain name tied to the cert"
  value       = aws_acm_certificate.this.domain_name
}
output "validated_certificate_arn" {
  value = aws_acm_certificate_validation.this.certificate_arn
}
