variable "region" {
  description = "AWS region"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the ALB to attach the WAF to"
  type        = string
}
