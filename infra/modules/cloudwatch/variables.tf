variable "region" {
  description = "AWS region for the dashboard"
  type        = string
}

variable "alb_load_balancer_name" {
  description = "ALB dimension for CloudWatch (e.g. app/my-alb/1234567890abcdef)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
}
