output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "http_listener_arn" {
  description = "ARN of the HTTP (80) listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS (443) listener"
  value       = aws_lb_listener.https.arn
}

output "blue_tg_name" {
  description = "Name of the blue target group"
  value       = aws_lb_target_group.blue.name
}

output "green_tg_name" {
  description = "Name of the green target group"
  value       = aws_lb_target_group.green.name
}

# Optional but handy if any module needs ARNs instead of names
output "blue_tg_arn" {
  description = "ARN of the blue target group"
  value       = aws_lb_target_group.blue.arn
}

output "green_tg_arn" {
  description = "ARN of the green target group"
  value       = aws_lb_target_group.green.arn
}
 output "alb_zone_id"{
  value = aws_lb.this.zone_id
 }