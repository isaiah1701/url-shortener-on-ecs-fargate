output "waf_name" {
  value = aws_wafv2_web_acl.main.name
}

output "waf_arn" {
  value = aws_wafv2_web_acl.main.arn
}

output "waf_alb_association_id" {
  value = aws_wafv2_web_acl_association.alb_assoc.id
}
